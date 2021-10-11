require "rails_helper"
RSpec.describe "Test Features" do
  let!(:case_log) { FactoryBot.create(:case_log, :in_progress) }
  let!(:empty_case_log) { FactoryBot.create(:case_log) }
  let(:id) { case_log.id }
  let(:status) { case_log.status }

  question_answers = {
    tenant_code: { type: "text", answer: "BZ737" },
    tenant_age: { type: "numeric", answer: 25 },
    tenant_gender: { type: "radio", answer: "Female" },
    tenant_ethnic_group: { type: "radio", answer: "Prefer not to say" },
    tenant_nationality: { type: "radio", answer: "Lithuania" },
    tenant_economic_status: { type: "radio", answer: "Jobseeker" },
    household_number_of_other_members: { type: "numeric", answer: 2 },
  }

  def fill_in_number_question(case_log_id, question, value)
    visit("/case_logs/#{case_log_id}/#{question}")
    fill_in("case-log-#{question.to_s.dasherize}-field", with: value)
    click_button("Save and continue")
  end

  def answer_all_questions_in_income_subsection
    visit("/case_logs/#{empty_case_log.id}/net_income")
    fill_in("case-log-net-income-field", with: 18_000)
    choose("case-log-net-income-frequency-yearly-field")
    click_button("Save and continue")
    choose("case-log-net-income-uc-proportion-all-field")
    click_button("Save and continue")
    choose("case-log-housing-benefit-housing-benefit-but-not-universal-credit-field")
    click_button("Save and continue")
  end

  describe "Create new log" do
    it "redirects to the task list for the new log" do
      visit("/case_logs")
      click_link("Create new log")
      id = CaseLog.order(created_at: :desc).first.id
      expect(page).to have_content("Tasklist for log #{id}")
    end
  end

  describe "Viewing a log" do
    context "tasklist page" do
      it "displays a tasklist header" do
        visit("/case_logs/#{id}")
        expect(page).to have_content("Tasklist for log #{id}")
        expect(page).to have_content("This submission is #{status}")
      end

      it "displays a section status" do
        visit("/case_logs/#{empty_case_log.id}")

        assert_selector ".govuk-tag", text: /Not started/, count: 8
        assert_selector ".govuk-tag", text: /Completed/, count: 0
        assert_selector ".govuk-tag", text: /Cannot start yet/, count: 1
      end

      it "shows the correct status if one section is completed" do
        answer_all_questions_in_income_subsection
        visit("/case_logs/#{empty_case_log.id}")

        assert_selector ".govuk-tag", text: /Not started/, count: 7
        assert_selector ".govuk-tag", text: /Completed/, count: 1
        assert_selector ".govuk-tag", text: /Cannot start yet/, count: 1
      end

      it "skips to the first section if no answers are completed" do
        visit("/case_logs/#{empty_case_log.id}")
        expect(page).to have_link("Skip to next incomplete section", href: /#household_characteristics/)
      end

      it "shows the number of completed sections if no sections are completed" do
        visit("/case_logs/#{empty_case_log.id}")
        expect(page).to have_content("You've completed 0 of 9 sections.")
      end

      it "shows the number of completed sections if one section is completed" do
        answer_all_questions_in_income_subsection
        visit("/case_logs/#{empty_case_log.id}")
        expect(page).to have_content("You've completed 1 of 9 sections.")
      end
    end

    it "displays the household questions when you click into that section" do
      visit("/case_logs/#{id}")
      click_link("Household characteristics")
      expect(page).to have_field("case-log-tenant-code-field")
      click_button("Save and continue")
      expect(page).to have_field("case-log-tenant-age-field")
      click_button("Save and continue")
      expect(page).to have_field("case-log-tenant-gender-male-field")
      visit page.driver.request.env["HTTP_REFERER"]
      expect(page).to have_field("case-log-tenant-age-field")
    end

    describe "form questions" do
      let(:case_log_with_checkbox_questions_answered) do
        FactoryBot.create(
          :case_log, :in_progress,
          accessibility_requirements_fully_wheelchair_accessible_housing: true,
          accessibility_requirements_level_access_housing: true
        )
      end

      it "can be accessed by url" do
        visit("/case_logs/#{id}/tenant_age")
        expect(page).to have_field("case-log-tenant-age-field")
      end

      it "updates model attributes correctly for each question" do
        question_answers.each do |question, hsh|
          type = hsh[:type]
          answer = hsh[:answer]
          original_value = case_log.send(question)
          visit("/case_logs/#{id}/#{question}")
          case type
          when "text"
            fill_in("case-log-#{question.to_s.dasherize}-field", with: answer)
          when "radio"
            choose("case-log-#{question.to_s.dasherize}-#{answer.parameterize}-field")
          else
            fill_in("case-log-#{question.to_s.dasherize}-field", with: answer)
          end
          expect { click_button("Save and continue") }.to change {
            case_log.reload.send(question.to_s)
          }.from(original_value).to(answer)
        end
      end

      it "updates total value of the rent", js: true do
        visit("/case_logs/#{id}/rent")

        fill_in("case-log-basic-rent-field", with: 3)
        expect(page).to have_field("case-log-total-charge-field", with: "3")

        fill_in("case-log-service-charge-field", with: 2)
        expect(page).to have_field("case-log-total-charge-field", with: "5")

        fill_in("case-log-personal-service-charge-field", with: 1)
        expect(page).to have_field("case-log-total-charge-field", with: "6")

        fill_in("case-log-support-charge-field", with: 4)
        expect(page).to have_field("case-log-total-charge-field", with: "10")
      end

      it "displays number answers in inputs if they are already saved" do
        visit("/case_logs/#{id}/previous_postcode")
        expect(page).to have_field("case-log-previous-postcode-field", with: "P0 5ST")
      end

      it "displays text answers in inputs if they are already saved" do
        visit("/case_logs/#{id}/tenant_age")
        expect(page).to have_field("case-log-tenant-age-field", with: "12")
      end

      it "displays checkbox answers in inputs if they are already saved" do
        visit("/case_logs/#{case_log_with_checkbox_questions_answered.id}/accessibility_requirements")
        # Something about our styling makes the selenium webdriver think the actual radio buttons are not visible so we pass false here
        expect(page).to have_checked_field(
          "case-log-accessibility-requirements-accessibility-requirements-fully-wheelchair-accessible-housing-field",
          visible: false,
        )
        expect(page).to have_unchecked_field(
          "case-log-accessibility-requirements-accessibility-requirements-wheelchair-access-to-essential-rooms-field",
          visible: false,
        )
        expect(page).to have_checked_field(
          "case-log-accessibility-requirements-accessibility-requirements-level-access-housing-field",
          visible: false,
        )
      end
    end

    describe "Back link directs correctly" do
      it "go back to tasklist page from tenant code" do
        visit("/case_logs/#{id}/tenant_code")
        click_link(text: "Back")
        expect(page).to have_content("Tasklist for log #{id}")
      end

      it "go back to tenant code page from tenant age page" do
        visit("/case_logs/#{id}/tenant_age")
        click_link(text: "Back")
        expect(page).to have_field("case-log-tenant-code-field")
      end
    end
  end

  describe "Form flow is correct" do
    context "given an ordered list of pages" do
      it "leads to the next one in the correct order" do
        pages = question_answers.keys
        pages[0..-2].each_with_index do |val, index|
          visit("/case_logs/#{id}/#{val}")
          click_button("Save and continue")
          expect(page).to have_current_path("/case_logs/#{id}/#{pages[index + 1]}")
        end
      end
    end
  end

  describe "check answers page" do
    let(:subsection) { "household_characteristics" }

    context "when the user needs to check their answers for a subsection" do
      it "can be visited by URL" do
        visit("case_logs/#{id}/#{subsection}/check_answers")
        expect(page).to have_content("Check the answers you gave for #{subsection.tr('_', ' ')}")
      end

      let(:last_question_for_subsection) { "household_number_of_other_members" }
      it "redirects to the check answers page when answering the last question and clicking save and continue" do
        fill_in_number_question(id, last_question_for_subsection, 0)
        expect(page).to have_current_path("/case_logs/#{id}/#{subsection}/check_answers")
      end

      it "has question headings based on the subsection" do
        visit("case_logs/#{id}/#{subsection}/check_answers")
        question_labels = ["Tenant code", "Tenant's age", "Tenant's gender", "Ethnicity", "Nationality", "Work", "Number of Other Household Members"]
        question_labels.each do |label|
          expect(page).to have_content(label)
        end
      end

      it "should display answers given by the user for the question in the subsection" do
        fill_in_number_question(empty_case_log.id, "tenant_age", 28)
        choose("case-log-tenant-gender-non-binary-field")
        click_button("Save and continue")
        visit("/case_logs/#{empty_case_log.id}/#{subsection}/check_answers")
        expect(page).to have_content("28")
        expect(page).to have_content("Non-binary")
      end

      it "should have an answer link for questions missing an answer" do
        visit("case_logs/#{empty_case_log.id}/#{subsection}/check_answers")
        assert_selector "a", text: /Answer\z/, count: 7
        assert_selector "a", text: "Change", count: 0
        expect(page).to have_link("Answer", href: "/case_logs/#{empty_case_log.id}/tenant_age")
      end

      it "should have a change link for answered questions" do
        fill_in_number_question(empty_case_log.id, "tenant_age", 28)
        visit("/case_logs/#{empty_case_log.id}/#{subsection}/check_answers")
        assert_selector "a", text: /Answer\z/, count: 6
        assert_selector "a", text: "Change", count: 1
        expect(page).to have_link("Change", href: "/case_logs/#{empty_case_log.id}/tenant_age")
      end

      it "should have a link pointing to the first question if no questions are answered" do
        visit("/case_logs/#{empty_case_log.id}/#{subsection}/check_answers")
        expect(page).to have_content("You answered 0 of 7 questions")
        expect(page).to have_link("Answer the missing questions", href: "/case_logs/#{empty_case_log.id}/tenant_code")
      end

      it "should have a link pointing to the next empty question if some questions are answered" do
        fill_in_number_question(empty_case_log.id, "net_income", 18_000)

        visit("/case_logs/#{empty_case_log.id}/income_and_benefits/check_answers")
        expect(page).to have_content("You answered 1 of 4 questions")
        expect(page).to have_link("Answer the missing questions", href: "/case_logs/#{empty_case_log.id}/net_income")
      end

      it "should not display the missing answer questions link if all questions are answered" do
        answer_all_questions_in_income_subsection
        expect(page).to have_content("You answered all the questions")
        assert_selector "a", text: "Answer the missing questions", count: 0
      end
    end
  end

  describe "Conditional questions" do
    context "given a page where some questions are only conditionally shown, depending on how you answer the first question" do
      it "initially hides conditional questions" do
        visit("/case_logs/#{id}/armed_forces")
        expect(page).not_to have_selector("#armed_forces_injured_div")
      end

      it "shows conditional questions if the required answer is selected and hides it again when a different answer option is selected", js: true do
        visit("/case_logs/#{id}/armed_forces")
        # Something about our styling makes the selenium webdriver think the actual radio buttons are not visible so we allow label click here
        choose("case-log-armed-forces-yes-a-regular-field", allow_label_click: true)
        expect(page).to have_selector("#armed_forces_injured_div")
        choose("case-log-armed-forces-injured-no-field", allow_label_click: true)
        expect(page).to have_checked_field("case-log-armed-forces-injured-no-field", visible: false)
        choose("case-log-armed-forces-no-field", allow_label_click: true)
        expect(page).not_to have_selector("#armed_forces_injured_div")
        choose("case-log-armed-forces-yes-a-regular-field", allow_label_click: true)
        expect(page).to have_unchecked_field("case-log-armed-forces-injured-no-field", visible: false)
      end
    end
  end
end

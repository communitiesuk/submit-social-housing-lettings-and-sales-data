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

  describe "Create new log" do
    it "redirects to the task list for the new log" do
      visit("/case_logs")
      click_link("Create new log")
      id = CaseLog.order(created_at: :desc).first.id
      expect(page).to have_content("Tasklist for log #{id}")
    end
  end

  describe "Viewing a log" do
    it "displays a tasklist header" do
      visit("/case_logs/#{id}")
      expect(page).to have_content("Tasklist for log #{id}")
      expect(page).to have_content("This submission is #{status}")
    end

    it "displays the household questions when you click into that section" do
      visit("/case_logs/#{id}")
      click_link("Household characteristics")
      expect(page).to have_field("tenant-code-field")
      click_button("Save and continue")
      expect(page).to have_field("tenant-age-field")
      click_button("Save and continue")
      expect(page).to have_field("tenant-gender-male-field")
      visit page.driver.request.env["HTTP_REFERER"]
      expect(page).to have_field("tenant-age-field")
    end

    describe "form questions" do
      it "can be accessed by url" do
        visit("/case_logs/#{id}/tenant_age")
        expect(page).to have_field("tenant-age-field")
      end

      it "updates model attributes correctly for each question" do
        question_answers.each do |question, hsh|
          type = hsh[:type]
          answer = hsh[:answer]
          original_value = case_log.send(question)
          visit("/case_logs/#{id}/#{question}")
          case type
          when "text"
            fill_in(question.to_s, with: answer)
          when "radio"
            choose("#{question.to_s.tr('_', '-')}-#{answer.parameterize}-field")
          else
            fill_in(question.to_s, with: answer)
          end
          expect { click_button("Save and continue") }.to change {
            case_log.reload.send(question.to_s)
          }.from(original_value).to(answer)
        end
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
        expect(page).to have_field("tenant-code-field")
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
        visit("/case_logs/#{id}/#{last_question_for_subsection}")
        fill_in(last_question_for_subsection, with: 0)
        click_button("Save and continue")
        expect(page).to have_current_path("/case_logs/#{id}/#{subsection}/check_answers")
      end

      it "has question headings based on the subsection" do
        visit("case_logs/#{id}/#{subsection}/check_answers")
        expect(page).to have_content("Tenant code")
        expect(page).to have_content("Tenant's age")
        expect(page).to have_content("Tenant's gender")
        expect(page).to have_content("Ethnicity")
        expect(page).to have_content("Nationality")
        expect(page).to have_content("Work")
        expect(page).to have_content("Number of Other Household Members")
      end
      
      it "should display answers given by the user for the question in the subsection" do
        visit("/case_logs/#{id}/tenant_age")
        fill_in("tenant_age", with: 28)
        click_button("Save and continue")
        choose("tenant-gender-non-binary-field")
        click_button("Save and continue")
        visit("/case_logs/#{id}/#{subsection}/check_answers")
        expect(page).to have_content("28")
        expect(page).to have_content("Non-binary")
      end 
      
      it "should have an answer link for questions missing an answer" do
        visit("case_logs/#{empty_case_log.id}/#{subsection}/check_answers")
        assert_selector "a", text: "Answer", count: 7
        assert_selector "a", text: "Change", count: 0
        expect(page).to have_link('Answer', href: "/case_logs/#{empty_case_log.id}/tenant_age")
      end

      it "should have a change link for answered questions" do 
        visit("/case_logs/#{empty_case_log.id}/tenant_age")
        fill_in("tenant_age", with: 28)
        click_button("Save and continue")
        visit("/case_logs/#{empty_case_log.id}/#{subsection}/check_answers")
        assert_selector "a", text: "Answer", count: 6
        assert_selector "a", text: "Change", count: 1
        expect(page).to have_link('Change', href: "/case_logs/#{empty_case_log.id}/tenant_age")
      end 
    end
  end
end

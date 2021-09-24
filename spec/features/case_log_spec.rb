require "rails_helper"
RSpec.describe "Test Features" do
  let!(:case_log) { FactoryBot.create(:case_log, :in_progress) }
  let!(:check_answers_case_log) { FactoryBot.create(:case_log, :near_check_answers_household_characteristics) }
  let(:id) { case_log.id }
  let(:status) { case_log.status }

  question_answers = {
    tenant_code: { type: "text", answer: "BZ737" },
    tenant_age: { type: "numeric", answer: 25 },
    tenant_gender: { type: "radio", answer: "1" },
    tenant_ethnic_group: { type: "radio", answer: "2" },
    tenant_nationality: { type: "radio", answer: "0" },
    tenant_economic_status: { type: "radio", answer: "4" },
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
      expect(page).to have_field("tenant-gender-0-field")
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
            choose("#{question.to_s.tr('_', '-')}-#{answer}-field")
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

    context "only one questions remains to be answered for the household characteristics section" do
      # it "redirects to the check answers page when answering the last question and clicking save and continue" do
      #   visit("/case_logs/#{check_answers_case_log.id}/household_number_of_other_members")
      #   fill_in("household_number_of_other_members", with: 0)
      #   click_button("Save and continue")
      #   expect(page).to have_current_path("/case_logs/#{check_answers_case_log.id}/check-answers")
      # end

      it "can be visited by URL" do
        visit("case_logs/#{case_log.id}/#{subsection}/check_answers")
        expect(page).to have_content("Check the answers you gave for #{subsection.tr('_', ' ')}")
      end
    end
  end
end

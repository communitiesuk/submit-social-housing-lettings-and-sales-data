require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Navigation" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:case_log) do
    FactoryBot.create(
      :case_log,
      :in_progress,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end
  let(:id) { case_log.id }
  let(:question_answers) do
    {
      tenant_code: { type: "text", answer: "BZ737", path: "tenant_code" },
      age1: { type: "numeric", answer: 25, path: "person_1_age" },
      sex1: { type: "radio", answer: "Female", path: "person_1_gender" },
      other_hhmemb: { type: "numeric", answer: 2, path: "household_number_of_other_members" },
    }
  end

  before do
    sign_in user
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
    it "questions can be accessed by url" do
      visit("/case_logs/#{id}/person_1_age")
      expect(page).to have_field("case-log-age1-field")
    end

    it "a question page leads to the next question defined in the form definition" do
      pages = question_answers.map { |_key, val| val[:path] }
      pages[0..-2].each_with_index do |val, index|
        visit("/case_logs/#{id}/#{val}")
        click_button("Save and continue")
        expect(page).to have_current_path("/case_logs/#{id}/#{pages[index + 1]}")
      end
    end

    describe "Back link directs correctly", js: true do
      it "go back to tasklist page from tenant code" do
        visit("/case_logs/#{id}")
        visit("/case_logs/#{id}/tenant_code")
        click_link(text: "Back")
        expect(page).to have_content("Tasklist for log #{id}")
      end

      it "go back to tenant code page from tenant age page", js: true do
        visit("/case_logs/#{id}/tenant_code")
        click_button("Save and continue")
        visit("/case_logs/#{id}/person_1_age")
        click_link(text: "Back")
        expect(page).to have_field("case-log-tenant-code-field")
      end

      it "doesn't get stuck in infinite loops", js: true do
        visit("/case_logs")
        visit("/case_logs/#{id}/net_income")
        fill_in("case-log-earnings-field", with: 740)
        choose("case-log-incfreq-weekly-field", allow_label_click: true)
        click_button("Save and continue")
        click_link(text: "Back")
        click_link(text: "Back")
        expect(page).to have_current_path("/case_logs")
      end

      context "when changing an answer from the check answers page", js: true do
        it "the back button routes correctly" do
          visit("/case_logs/#{id}/household_characteristics/check_answers")
          first("a", text: /Answer/).click
          click_link("Back")
          expect(page).to have_current_path("/case_logs/#{id}/household_characteristics/check_answers")
        end
      end
    end
  end
end

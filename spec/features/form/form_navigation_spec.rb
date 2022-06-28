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
      created_by: user,
    )
  end
  let(:empty_case_log) do
    FactoryBot.create(
      :case_log,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
      created_by: user,
    )
  end

  let(:id) { case_log.id }
  let(:question_answers) do
    {
      tenancycode: { type: "text", answer: "BZ737", path: "tenant-code-test" },
      age1: { type: "numeric", answer: 25, path: "person-1-age" },
      sex1: { type: "radio", answer: "Female", path: "person-1-gender" },
      ecstat1: { type: "radio", answer: 3, path: "person-1-working-situation" },
      hhmemb: { type: "numeric", answer: 1, path: "household-number-of-members" },
    }
  end

  before do
    sign_in user
  end

  describe "Create a new lettings log" do
    it "redirects to the task list for the new log" do
      visit("/logs")
      click_button("Create a new lettings log")
      id = CaseLog.order(created_at: :desc).first.id
      expect(page).to have_content("Log #{id}")
    end
  end

  describe "Viewing a log", js: true do
    it "questions can be accessed by url" do
      visit("/logs/#{id}/person-1-age")
      expect(page).to have_field("case-log-age1-field")
    end

    it "a question page leads to the next question defined in the form definition" do
      pages = question_answers.map { |_key, val| val[:path] }
      pages[0..-2].each_with_index do |val, index|
        visit("/logs/#{id}/#{val}")
        click_button("Save and continue")
        expect(page).to have_current_path("/logs/#{id}/#{pages[index + 1]}")
      end
    end

    it "a question page has a link allowing you to cancel your input and return to the check answers page" do
      visit("logs/#{id}/tenant-code-test")
      click_link(text: "Cancel")
      expect(page).to have_current_path("/logs/#{id}/setup/check-answers")
    end

    it "a question page has a Skip for now link that lets you move on to the next question without inputting anything" do
      visit("logs/#{empty_case_log.id}/tenant-code-test")
      click_link(text: "Skip for now")
      expect(page).to have_current_path("/logs/#{empty_case_log.id}/person-1-age")
    end

    describe "Back link directs correctly", js: true do
      it "go back to tasklist page from tenant code" do
        visit("/logs/#{id}")
        visit("/logs/#{id}/tenant-code-test")
        click_link(text: "Back")
        expect(page).to have_content("Log #{id}")
      end

      it "go back to tenant code page from tenant age page", js: true do
        visit("/logs/#{id}/tenant-code-test")
        click_button("Save and continue")
        visit("/logs/#{id}/person-1-age")
        click_link(text: "Back")
        expect(page).to have_field("case-log-tenancycode-field")
      end

      it "doesn't get stuck in infinite loops", js: true do
        visit("/logs")
        visit("/logs/#{id}/net-income")
        fill_in("case-log-earnings-field", with: 740)
        choose("case-log-incfreq-1-field", allow_label_click: true)
        click_button("Save and continue")
        click_link(text: "Back")
        click_link(text: "Back")
        expect(page).to have_current_path("/logs")
      end

      context "when changing an answer from the check answers page", js: true do
        it "the back button routes correctly" do
          visit("/logs/#{id}/household-characteristics/check-answers")
          first("a", text: /Answer/).click
          click_link("Back")
          expect(page).to have_current_path("/logs/#{id}/household-characteristics/check-answers")
        end
      end
    end
  end
end

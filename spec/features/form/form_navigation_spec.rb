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
      tenant_code: { type: "text", answer: "BZ737", path: "tenant-code" },
      age1: { type: "numeric", answer: 25, path: "person-1-age" },
      sex1: { type: "radio", answer: "Female", path: "person-1-gender" },
      ecstat1: {type: "radio", answer: 3, path: "person-1-working-situation"},
      other_hhmemb: { type: "numeric", answer: 2, path: "household-number-of-other-members" },
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

  describe "Viewing a log" do
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

    describe "Back link directs correctly", js: true do
      it "go back to tasklist page from tenant code" do
        visit("/logs/#{id}")
        visit("/logs/#{id}/tenant-code")
        click_link(text: "Back")
        expect(page).to have_content("Log #{id}")
      end

      it "go back to tenant code page from tenant age page", js: true do
        visit("/logs/#{id}/tenant-code")
        click_button("Save and continue")
        visit("/logs/#{id}/person-1-age")
        click_link(text: "Back")
        expect(page).to have_field("case-log-tenant-code-field")
      end

      it "doesn't get stuck in infinite loops", js: true do
        visit("/logs")
        visit("/logs/#{id}/net-income")
        fill_in("case-log-earnings-field", with: 740)
        choose("case-log-incfreq-0-field", allow_label_click: true)
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

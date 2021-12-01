require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Conditional Questions" do
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

  before do
    sign_in user
  end

  context "given a page where some questions are only conditionally shown, depending on how you answer the first question" do
    it "initially hides conditional questions" do
      visit("/case-logs/#{id}/armed-forces")
      expect(page).not_to have_selector("#armed_forces_injured_div")
    end

    it "shows conditional questions if the required answer is selected and hides it again when a different answer option is selected", js: true do
      visit("/case-logs/#{id}/armed-forces")
      # Something about our styling makes the selenium webdriver think the actual radio buttons are not visible so we allow label click here
      choose("case-log-armedforces-a-current-or-former-regular-in-the-uk-armed-forces-exc-national-service-field", allow_label_click: true)
      expect(page).to have_selector("#reservist_div")
      choose("case-log-reservist-no-field", allow_label_click: true)
      expect(page).to have_checked_field("case-log-reservist-no-field", visible: false)
      choose("case-log-armedforces-no-field", allow_label_click: true)
      expect(page).not_to have_selector("#reservist_div")
      choose("case-log-armedforces-a-current-or-former-regular-in-the-uk-armed-forces-exc-national-service-field", allow_label_click: true)
      expect(page).to have_unchecked_field("case-log-reservist-no-field", visible: false)
    end
  end
end

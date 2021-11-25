require "rails_helper"

RSpec.describe "Form Conditional Questions" do
  let(:case_log) { FactoryBot.create(:case_log, :in_progress) }
  let(:id) { case_log.id }

  before do
    allow_any_instance_of(CaseLogsController).to receive(:authenticate_user!).and_return(true)
  end

  context "given a page where some questions are only conditionally shown, depending on how you answer the first question" do
    it "initially hides conditional questions" do
      visit("/case_logs/#{id}/armed_forces")
      expect(page).not_to have_selector("#armed_forces_injured_div")
    end

    it "shows conditional questions if the required answer is selected and hides it again when a different answer option is selected", js: true do
      visit("/case_logs/#{id}/armed_forces")
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

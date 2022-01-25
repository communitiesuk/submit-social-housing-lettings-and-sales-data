require "rails_helper"
require_relative "helpers"
require_relative "../../request_helper"

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
    RequestHelper.stub_http_requests
    sign_in user
  end

  context "given a page where some questions are only conditionally shown, depending on how you answer the first question" do
    it "initially hides conditional questions" do
      visit("/logs/#{id}/armed-forces")
      expect(page).not_to have_selector("#armed_forces_injured_div")
    end

    it "shows conditional questions if the required answer is selected and hides it again when a different answer option is selected", js: true do
      visit("/logs/#{id}/armed-forces")
      # Something about our styling makes the selenium webdriver think the actual radio buttons are not visible so we allow label click here
      choose("case-log-armedforces-a-current-or-former-regular-in-the-uk-armed-forces-excluding-national-service-field", allow_label_click: true)
      fill_in("case-log-leftreg-field", with: "text")
      choose("case-log-armedforces-no-field", allow_label_click: true)
      expect(page).not_to have_field("case-log-leftreg-field")
      choose("case-log-armedforces-a-current-or-former-regular-in-the-uk-armed-forces-excluding-national-service-field", allow_label_click: true)
      expect(page).to have_field("case-log-leftreg-field", with: "")
    end
  end
end

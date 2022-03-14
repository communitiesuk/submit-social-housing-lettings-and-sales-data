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

  context "with a page where some questions are only conditionally shown, depending on how you answer the first question" do
    it "initially hides conditional questions" do
      visit("/logs/#{id}/armed-forces")
      expect(page).not_to have_selector("#armed_forces_injured_div")
    end

    it "shows conditional questions if the required answer is selected and hides it again when a different answer option is selected", js: true do
      visit("/logs/#{id}/armed-forces")
      # Something about our styling makes the selenium webdriver think the actual radio buttons are not visible so we allow label click here
      choose("case-log-armedforces-0-field", allow_label_click: true)
      fill_in("case-log-leftreg-field", with: "text")
      choose("case-log-armedforces-1-field", allow_label_click: true)
      expect(page).not_to have_field("case-log-leftreg-field")
      choose("case-log-armedforces-0-field", allow_label_click: true)
      expect(page).to have_field("case-log-leftreg-field", with: "")
    end
  end

  context "when a conditional question has a saved answer", js: true do
    it "is displayed correctly" do
      case_log.update!(postcode_known: 1, property_postcode: "NW1 6RT")
      visit("/logs/#{id}/property-postcode")
      expect(page).to have_field("case-log-property-postcode-field", with: "NW1 6RT")
    end
  end
end

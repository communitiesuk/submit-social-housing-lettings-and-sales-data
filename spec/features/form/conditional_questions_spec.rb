require "rails_helper"
require_relative "helpers"

RSpec.describe "Form Conditional Questions" do
  include Helpers
  let(:user) { FactoryBot.create(:user) }
  let(:lettings_log) do
    FactoryBot.create(
      :lettings_log,
      :in_progress,
      owning_organisation: user.organisation,
      managing_organisation: user.organisation,
    )
  end
  let(:id) { lettings_log.id }

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
      choose("lettings-log-armedforces-1-field", allow_label_click: true)
      fill_in("lettings-log-leftreg-field", with: "text")
      choose("lettings-log-armedforces-4-field", allow_label_click: true)
      expect(page).not_to have_field("lettings-log-leftreg-field")
      choose("lettings-log-armedforces-1-field", allow_label_click: true)
      expect(page).to have_field("lettings-log-leftreg-field", with: "")
    end
  end

  context "when a conditional question has a saved answer", js: true do
    it "is displayed correctly" do
      lettings_log.update!(postcode_known: 1, postcode_full: "NW1 6RT")
      visit("/logs/#{id}/property-postcode")
      expect(page).to have_field("lettings-log-postcode-full-field", with: "NW1 6RT")
    end
  end
end

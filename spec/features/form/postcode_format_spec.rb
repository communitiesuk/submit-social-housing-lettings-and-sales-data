require "rails_helper"
require_relative "helpers"

RSpec.describe "Postcode formatting" do
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

  context "when a postcode is input" do
    # it "for a 6 character postcode a space will be after the third character" do
    #   visit("/logs/#{id}/property-postcode")
    #   fill_in("case-log-postcode-full-field", with: "aa11aa")
    #   click_button("Save and continue")
    #   visit("/logs/#{id}/property-information/check-answers")
    #   expect(page).to have_text("AA1 1AA")
    # end

    it "for a 5 character postcode a space will be after the second character" do
      visit("/logs/#{id}/property-postcode")
      fill_in("case-log-postcode-full-field", with: "a9 9aa")
      click_button("Save and continue")
      visit("/logs/#{id}/property-information/check-answers")
      expect(page).to have_text("A9 9AA")
    end
  end
end

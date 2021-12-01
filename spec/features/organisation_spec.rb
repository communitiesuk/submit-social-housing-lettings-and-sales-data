require "rails_helper"
require_relative "form/helpers"

RSpec.describe "User Features" do
  include Helpers
  let!(:user) { FactoryBot.create(:user) }
  let(:organisation) { user.organisation }
  let(:org_id) { organisation.id }

  before do
    sign_in user
  end

  context "Organisation page" do
    it "default to organisation details" do
      visit("/case_logs")
      click_link("Your organisation")
      expect(page).to have_content(user.organisation.name)
    end

    it "can switch tabs" do
      visit("/organisations/#{org_id}")
      click_link("Users")
      expect(page).to have_current_path("/organisations/#{org_id}/users")
      click_link("Details")
      expect(page).to have_current_path("/organisations/#{org_id}/details")
    end
  end
end

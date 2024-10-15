require "rails_helper"

RSpec.describe "OrganisationRelationships", type: :feature do
  context "when viewing the stock owners page" do
    let(:user) { create(:user) }

    before do
      sign_in user
      create(:organisation_relationship, parent_organisation: create(:organisation, name: "Zeta"), child_organisation: user.organisation)
      create(:organisation_relationship, parent_organisation: create(:organisation, name: "Alpha"), child_organisation: user.organisation)
      create(:organisation_relationship, parent_organisation: create(:organisation, name: "Gamma"), child_organisation: user.organisation)
      create(:organisation_relationship, parent_organisation: create(:organisation, name: "ABACUS"), child_organisation: user.organisation)
      visit("organisations/#{user.organisation.id}/stock-owners")
    end

    it "displays stock owners in alphabetical order" do
      expect(page).to have_content(/ABACUS.*Alpha.*Gamma.*Zeta/m)
    end
  end

  context "when viewing the managing agents page" do
    let(:user) { create(:user) }

    before do
      sign_in user
      create(:organisation_relationship, parent_organisation: user.organisation, child_organisation: create(:organisation, name: "Zeta"))
      create(:organisation_relationship, parent_organisation: user.organisation, child_organisation: create(:organisation, name: "Alpha"))
      create(:organisation_relationship, parent_organisation: user.organisation, child_organisation: create(:organisation, name: "Gamma"))
      create(:organisation_relationship, parent_organisation: user.organisation, child_organisation: create(:organisation, name: "ABACUS"))
      visit("organisations/#{user.organisation.id}/managing-agents")
    end

    it "displays stock owners in alphabetical order" do
      expect(page).to have_content(/ABACUS.*Alpha.*Gamma.*Zeta/m)
    end
  end
end

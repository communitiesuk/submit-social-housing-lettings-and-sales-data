require "rails_helper"

RSpec.describe MergeRequestsHelper do
  describe "#merging_organisations_without_users_text" do
    context "with 1 organisation" do
      let(:organisation) { build(:organisation, name: "Org 1") }

      it "returns the correct text" do
        expect(merging_organisations_without_users_text([organisation])).to eq("Org 1 has no users.")
      end
    end

    context "with 2 organisations" do
      let(:organisation) { build(:organisation, name: "Org 1") }
      let(:organisation_2) { build(:organisation, name: "Org 2") }

      it "returns the correct text" do
        expect(merging_organisations_without_users_text([organisation, organisation_2])).to eq("Org 1 and Org 2 have no users.")
      end
    end

    context "with 3 organisations" do
      let(:organisation) { build(:organisation, name: "Org 1") }
      let(:organisation_2) { build(:organisation, name: "Org 2") }
      let(:organisation_3) { build(:organisation, name: "Org 3") }

      it "returns the correct text" do
        expect(merging_organisations_without_users_text([organisation, organisation_2, organisation_3])).to eq("Org 1, Org 2, and Org 3 have no users.")
      end
    end
  end

  describe "#link_to_merging_organisation_users" do
    context "with 1 organisation user" do
      let(:organisation) { create(:organisation, name: "Org 1") }

      it "returns the correct link" do
        expect(link_to_merging_organisation_users(organisation)).to include("View 1 Org 1 user (opens in a new tab)")
        expect(link_to_merging_organisation_users(organisation)).to include(users_organisation_path(organisation))
      end
    end

    context "with multiple organisation users" do
      let(:organisation) { create(:organisation, name: "Org 1") }

      before do
        create(:user, organisation:)
      end

      it "returns the correct link" do
        expect(link_to_merging_organisation_users(organisation)).to include("View all 2 Org 1 users (opens in a new tab)")
        expect(link_to_merging_organisation_users(organisation)).to include(users_organisation_path(organisation))
      end
    end
  end

  describe "#merging_organisations_without_schemes_text" do
    context "with 1 organisation" do
      let(:organisation) { build(:organisation, name: "Org 1") }

      it "returns the correct text" do
        expect(merging_organisations_without_schemes_text([organisation])).to eq("Org 1 has no schemes.")
      end
    end

    context "with 2 organisations" do
      let(:organisation) { build(:organisation, name: "Org 1") }
      let(:organisation_2) { build(:organisation, name: "Org 2") }

      it "returns the correct text" do
        expect(merging_organisations_without_schemes_text([organisation, organisation_2])).to eq("Org 1 and Org 2 have no schemes.")
      end
    end

    context "with 3 organisations" do
      let(:organisation) { build(:organisation, name: "Org 1") }
      let(:organisation_2) { build(:organisation, name: "Org 2") }
      let(:organisation_3) { build(:organisation, name: "Org 3") }

      it "returns the correct text" do
        expect(merging_organisations_without_schemes_text([organisation, organisation_2, organisation_3])).to eq("Org 1, Org 2, and Org 3 have no schemes.")
      end
    end
  end

  describe "#link_to_merging_organisation_schemes" do
    context "with 1 organisation scheme" do
      let(:organisation) { create(:organisation, name: "Org 1") }

      before do
        create(:scheme, owning_organisation: organisation)
      end

      it "returns the correct link" do
        expect(link_to_merging_organisation_schemes(organisation)).to include("View 1 Org 1 scheme (opens in a new tab)")
        expect(link_to_merging_organisation_schemes(organisation)).to include(schemes_organisation_path(organisation))
      end
    end

    context "with multiple organisation schemes" do
      let(:organisation) { create(:organisation, name: "Org 1") }

      before do
        create_list(:scheme, 2, owning_organisation: organisation)
      end

      it "returns the correct link" do
        expect(link_to_merging_organisation_schemes(organisation)).to include("View all 2 Org 1 schemes (opens in a new tab)")
        expect(link_to_merging_organisation_schemes(organisation)).to include(schemes_organisation_path(organisation))
      end
    end
  end

  describe "when creating relationship outcomes content" do
    let(:stock_owner1) { create(:organisation, name: "Stock owner 1") }
    let(:stock_owner2) { create(:organisation, name: "Stock owner 2") }
    let(:managing_agent1) { create(:organisation, name: "Managing agent 1") }
    let(:managing_agent2) { create(:organisation, name: "Managing agent 2") }
    let(:absorbing_organisation) { create(:organisation, name: "Absorbing Org") }
    let(:merging_organisations) { create_list(:organisation, 2) { |org, i| org.name = "Dummy Org #{i + 1}" } }
    let(:merge_request) { create(:merge_request, absorbing_organisation:, merging_organisations:) }

    context "when there are no relationships" do
      it "returns text stating there are no stock owners" do
        expect(stock_owners_text(merge_request)).to eq("Absorbing Org, Dummy Org 1, and Dummy Org 2 have no stock owners.<br><br>")
      end

      it "returns text stating there are no managing agents" do
        expect(managing_agent_text(merge_request)).to eq("Absorbing Org, Dummy Org 1, and Dummy Org 2 have no managing agents.<br><br>")
      end
    end

    context "when there are stock owners" do
      before do
        create(:organisation_relationship, child_organisation: absorbing_organisation, parent_organisation: stock_owner1)
        create(:organisation_relationship, child_organisation: merging_organisations.first, parent_organisation: stock_owner2)
        create(:organisation_relationship, child_organisation: merging_organisations.first, parent_organisation: stock_owner1)
      end

      it "returns text stating the relationships" do
        expect(stock_owners_text(merge_request)).to include("Some of the organisations merging have common stock owners.")
        expect(stock_owners_text(merge_request)).to include("Dummy Org 2 has no stock owners.")
        expect(stock_owners_text(merge_request)).to include("<a class=\"govuk-link\" target=\"_blank\" href=\"/organisations/#{merging_organisations.first.id}/stock-owners\">View all 2 Dummy Org 1 stock owners (opens in a new tab)</a>")
      end
    end

    context "when there are managing agents" do
      before do
        create(:organisation_relationship, parent_organisation: absorbing_organisation, child_organisation: managing_agent1)
        create(:organisation_relationship, parent_organisation: absorbing_organisation, child_organisation: managing_agent2)
        create(:organisation_relationship, parent_organisation: merging_organisations.first, child_organisation: managing_agent2)
      end

      it "returns text stating the relationships" do
        expect(managing_agent_text(merge_request)).to include("Some of the organisations merging have common managing agents.")
        expect(managing_agent_text(merge_request)).to include("Dummy Org 2 has no managing agents.")
        expect(managing_agent_text(merge_request)).to include("<a class=\"govuk-link\" target=\"_blank\" href=\"/organisations/#{merging_organisations.first.id}/managing-agents\">View the 1 Dummy Org 1 managing agent (opens in a new tab)</a>")
      end
    end
  end
end

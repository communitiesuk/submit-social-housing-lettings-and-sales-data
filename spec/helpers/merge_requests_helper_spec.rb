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
end

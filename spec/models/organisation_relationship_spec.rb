require "rails_helper"

RSpec.describe OrganisationRelationship do
  let(:parent_organisation) { create(:organisation) }
  let(:child_organisation) { create(:organisation) }

  context "when a relationship exists" do
    subject!(:relationship) do
      described_class.create!(parent_organisation:,
                              child_organisation:)
    end

    describe "parent#managing_agents" do
      it "includes child" do
        expect(parent_organisation.managing_agents).to include(child_organisation)
      end
    end

    describe "child#stock_owners" do
      it "includes parent" do
        expect(child_organisation.stock_owners).to include(parent_organisation)
      end
    end
  end
end

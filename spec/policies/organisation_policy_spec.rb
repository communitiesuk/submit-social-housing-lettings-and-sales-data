require "rails_helper"
# rubocop:disable RSpec/RepeatedExample

RSpec.describe OrganisationPolicy do
  subject(:policy) { described_class }

  let(:organisation) { FactoryBot.create(:organisation) }
  let(:data_provider) { FactoryBot.create(:user, :data_provider) }
  let(:data_coordinator) { FactoryBot.create(:user, :data_coordinator) }
  let(:support) { FactoryBot.create(:user, :support) }

  permissions :deactivate? do
    it "does not permit data providers to deactivate an organisation" do
      expect(policy).not_to permit(data_provider, organisation)
    end

    it "does not permit data coordinators to deactivate an organisation" do
      expect(policy).not_to permit(data_coordinator, data_provider)
    end

    it "permits support users to deactivate an organisation" do
      expect(policy).to permit(support, data_provider)
    end
  end

  permissions :reactivate? do
    it "does not permit data providers to reactivate an organisation" do
      expect(policy).not_to permit(data_provider, organisation)
    end

    it "does not permit data coordinators to reactivate an organisation" do
      expect(policy).not_to permit(data_coordinator, data_provider)
    end

    it "permits support users to reactivate an organisation" do
      expect(policy).to permit(support, data_provider)
    end
  end
end
# rubocop:enable RSpec/RepeatedExample

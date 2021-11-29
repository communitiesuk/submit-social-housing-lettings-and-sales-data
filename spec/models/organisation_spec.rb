require "rails_helper"

RSpec.describe Organisation, type: :model do
  describe "#new" do
    let(:user) { FactoryBot.create(:user) }
    let(:organisation) { user.organisation }

    it "has expected fields" do
      expect(organisation.attribute_names).to include("name", "phone", "org_type")
    end

    it "has users" do
      expect(organisation.users.first).to eq(user)
    end

    context "case logs" do
      let(:other_organisation) { FactoryBot.create(:organisation) }
      let!(:owned_case_log) do
        FactoryBot.create(
          :case_log,
          owning_organisation: organisation,
          managing_organisation: other_organisation
        )
      end
      let!(:managed_case_log) do
        FactoryBot.create(
          :case_log,
          owning_organisation: other_organisation,
          managing_organisation: organisation
        )
      end

      it "has owned case logs" do
        expect(organisation.owned_case_logs.first).to eq(owned_case_log)
      end

      it "has managed case logs" do
        expect(organisation.managed_case_logs.first).to eq(managed_case_log)
      end
    end
  end
end

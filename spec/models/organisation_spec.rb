require "rails_helper"

RSpec.describe Organisation, type: :model do
  describe "#new" do
    let(:user) { FactoryBot.create(:user) }
    let(:organisation) { user.organisation }

    it "has expected fields" do
      expect(organisation.attribute_names).to include("name", "phone", "provider_type")
    end

    it "has users" do
      expect(organisation.users.first).to eq(user)
    end

    it "validates provider_type presence" do
      expect { FactoryBot.create(:organisation, provider_type: nil) }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Provider type can't be blank")
    end

    context "with case logs" do
      let(:other_organisation) { FactoryBot.create(:organisation) }
      let!(:owned_case_log) do
        FactoryBot.create(
          :case_log,
          :completed,
          owning_organisation: organisation,
          managing_organisation: other_organisation,
        )
      end
      let!(:managed_case_log) do
        FactoryBot.create(
          :case_log,
          owning_organisation: other_organisation,
          managing_organisation: organisation,
        )
      end

      it "has owned case logs" do
        expect(organisation.owned_case_logs.first).to eq(owned_case_log)
      end

      it "has managed case logs" do
        expect(organisation.managed_case_logs.first).to eq(managed_case_log)
      end

      it "has case logs" do
        expect(organisation.case_logs.to_a).to eq([owned_case_log, managed_case_log])
      end

      it "has case log status helper methods" do
        expect(organisation.completed_case_logs.to_a).to eq([owned_case_log])
        expect(organisation.not_completed_case_logs.to_a).to eq([managed_case_log])
      end
    end
  end

  describe "paper trail" do
    let(:organisation) { FactoryBot.create(:organisation) }

    it "creates a record of changes to a log" do
      expect { organisation.update!(name: "new test name") }.to change(organisation.versions, :count).by(1)
    end

    it "allows case logs to be restored to a previous version" do
      organisation.update!(name: "new test name")
      expect(organisation.paper_trail.previous_version.name).to eq("DLUHC")
    end
  end
end

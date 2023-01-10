require "rails_helper"

RSpec.describe Organisation, type: :model do
  describe "#new" do
    let(:user) { FactoryBot.create(:user) }
    let!(:organisation) { user.organisation }
    let!(:scheme) { FactoryBot.create(:scheme, owning_organisation: organisation, managing_organisation: organisation) }

    it "has expected fields" do
      expect(organisation.attribute_names).to include("name", "phone", "provider_type")
    end

    it "has users" do
      expect(organisation.users.first).to eq(user)
    end

    it "has managed_schemes" do
      expect(organisation.managed_schemes.first).to eq(scheme)
    end

    it "has owned_schemes" do
      expect(organisation.owned_schemes.first).to eq(scheme)
    end

    it "validates provider_type presence" do
      expect { FactoryBot.create(:organisation, provider_type: nil) }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Provider type #{I18n.t('validations.organisation.provider_type_missing')}")
    end

    context "with parent/child associations", :aggregate_failures do
      let!(:child_organisation) { FactoryBot.create(:organisation, name: "DLUHC Child") }
      let!(:grandchild_organisation) { FactoryBot.create(:organisation, name: "DLUHC Grandchild") }

      before do
        FactoryBot.create(
          :organisation_relationship,
          child_organisation:,
          parent_organisation: organisation,
        )

        FactoryBot.create(
          :organisation_relationship,
          child_organisation: grandchild_organisation,
          parent_organisation: child_organisation,
        )
      end

      it "has correct child_organisations" do
        expect(organisation.child_organisations).to eq([child_organisation])
        expect(child_organisation.child_organisations).to eq([grandchild_organisation])
      end

      it "has correct parent_organisations" do
        expect(child_organisation.parent_organisations).to eq([organisation])
        expect(grandchild_organisation.parent_organisations).to eq([child_organisation])
      end
    end

    context "with owning association", :aggregate_failures do
      let!(:child_organisation) { FactoryBot.create(:organisation, name: "DLUHC Child") }
      let!(:grandchild_organisation) { FactoryBot.create(:organisation, name: "DLUHC Grandchild") }

      before do
        FactoryBot.create(
          :organisation_relationship,
          child_organisation:,
          parent_organisation: organisation,
        )

        FactoryBot.create(
          :organisation_relationship,
          child_organisation: grandchild_organisation,
          parent_organisation: child_organisation,
        )
      end

      it "has correct stock_owners" do
        expect(child_organisation.stock_owners).to eq([organisation])
        expect(grandchild_organisation.stock_owners).to eq([child_organisation])
      end
    end

    context "with managing association", :aggregate_failures do
      let!(:child_organisation) { FactoryBot.create(:organisation, name: "DLUHC Child") }
      let!(:grandchild_organisation) { FactoryBot.create(:organisation, name: "DLUHC Grandchild") }

      before do
        FactoryBot.create(
          :organisation_relationship,
          child_organisation:,
          parent_organisation: organisation,
        )

        FactoryBot.create(
          :organisation_relationship,
          child_organisation: grandchild_organisation,
          parent_organisation: child_organisation,
        )
      end

      it "has correct managing_agents" do
        expect(organisation.managing_agents).to eq([child_organisation])
        expect(child_organisation.managing_agents).to eq([grandchild_organisation])
        expect(grandchild_organisation.managing_agents).to eq([])
      end
    end

    context "with data protection confirmations" do
      before do
        FactoryBot.create(:data_protection_confirmation, organisation:, confirmed: false, created_at: Time.utc(2018, 0o6, 0o5, 10, 36, 49))
        FactoryBot.create(:data_protection_confirmation, organisation:, created_at: Time.utc(2019, 0o6, 0o5, 10, 36, 49))
      end

      it "takes the most recently created" do
        expect(organisation.data_protection_confirmed?).to be true
      end
    end

    context "when the organisation only uses specific rent periods" do
      let(:rent_period_mappings) do
        { "2" => { "value" => "Weekly for 52 weeks" }, "3" => { "value" => "Every 2 weeks" } }
      end

      before do
        FactoryBot.create(:organisation_rent_period, organisation:, rent_period: 2)
        FactoryBot.create(:organisation_rent_period, organisation:, rent_period: 3)

        # Unmapped and ignored by `rent_period_labels`
        FactoryBot.create(:organisation_rent_period, organisation:, rent_period: 10)
        allow(RentPeriod).to receive(:rent_period_mappings).and_return(rent_period_mappings)
      end

      it "has rent periods associated" do
        expect(organisation.rent_periods).to eq([2, 3, 10])
      end

      it "maps the rent periods to display values" do
        expect(organisation.rent_period_labels).to eq(["Weekly for 52 weeks", "Every 2 weeks"])
      end
    end

    context "when the organisation has not specified which rent periods it uses" do
      it "displays `all`" do
        expect(organisation.rent_period_labels).to eq(%w[All])
      end
    end

    context "with lettings logs" do
      let(:other_organisation) { FactoryBot.create(:organisation) }
      let!(:owned_lettings_log) do
        FactoryBot.create(
          :lettings_log,
          :completed,
          managing_organisation: other_organisation,
          created_by: user,
        )
      end
      let!(:managed_lettings_log) do
        FactoryBot.create(
          :lettings_log,
          created_by: user,
        )
      end

      it "has owned lettings logs" do
        expect(organisation.owned_lettings_logs.first).to eq(owned_lettings_log)
      end

      it "has managed lettings logs" do
        expect(organisation.managed_lettings_logs.first).to eq(managed_lettings_log)
      end

      it "has lettings logs" do
        expect(organisation.lettings_logs.to_a).to match_array([owned_lettings_log, managed_lettings_log])
      end

      it "has lettings log status helper methods" do
        expect(organisation.completed_lettings_logs.to_a).to eq([owned_lettings_log])
        expect(organisation.not_completed_lettings_logs.to_a).to eq([managed_lettings_log])
      end
    end
  end

  describe "paper trail" do
    let(:organisation) { FactoryBot.create(:organisation) }

    it "creates a record of changes to a log" do
      expect { organisation.update!(name: "new test name") }.to change(organisation.versions, :count).by(1)
    end

    it "allows lettings logs to be restored to a previous version" do
      organisation.update!(name: "new test name")
      expect(organisation.paper_trail.previous_version.name).to eq("DLUHC")
    end
  end

  describe "delete cascade" do
    context "when the organisation is deleted" do
      let!(:organisation) { FactoryBot.create(:organisation) }
      let!(:user) { FactoryBot.create(:user, :support, last_sign_in_at: Time.zone.now, organisation:) }
      let!(:scheme_to_delete) { FactoryBot.create(:scheme, owning_organisation: user.organisation) }
      let!(:log_to_delete) { FactoryBot.create(:lettings_log, owning_organisation: user.organisation) }
      let!(:sales_log_to_delete) { FactoryBot.create(:sales_log, owning_organisation: user.organisation) }

      context "when organisation is deleted" do
        it "child relationships ie logs, schemes and users are deleted too - application" do
          organisation.destroy!
          expect { organisation.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect { LettingsLog.find(log_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { Scheme.find(scheme_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { SalesLog.find(sales_log_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "child relationships ie logs, schemes and users are deleted too - database" do
          ActiveRecord::Base.connection.exec_query("DELETE FROM organisations WHERE id = #{organisation.id};")
          expect { LettingsLog.find(log_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { Scheme.find(scheme_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
          expect { SalesLog.find(sales_log_to_delete.id) }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end

  describe "scopes" do
    before do
      FactoryBot.create(:organisation, name: "Joe Bloggs")
      FactoryBot.create(:organisation, name: "Tom Smith")
    end

    context "when searching by name" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by_name("Joe").count).to eq(1)
        expect(described_class.search_by_name("joe").count).to eq(1)
      end
    end

    context "when searching by all searchable field" do
      it "returns case insensitive matching records" do
        expect(described_class.search_by("Joe").count).to eq(1)
        expect(described_class.search_by("joe").count).to eq(1)
      end
    end
  end
end

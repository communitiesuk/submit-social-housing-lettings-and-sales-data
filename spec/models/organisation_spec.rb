require "rails_helper"

RSpec.describe Organisation, type: :model do
  describe "#new" do
    let(:user) { create(:user) }
    let!(:organisation) { user.organisation }
    let!(:scheme) { create(:scheme, owning_organisation: organisation) }

    it "has expected fields" do
      expect(organisation.attribute_names).to include("name", "phone", "provider_type")
    end

    it "has owned_schemes" do
      expect(organisation.owned_schemes.first).to eq(scheme)
    end

    it "validates provider_type presence" do
      expect { create(:organisation, provider_type: nil) }
        .to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Provider type #{I18n.t('validations.organisation.provider_type_missing')}")
    end

    it "validates uniqueness of name" do
      org = build(:organisation, name: organisation.name.downcase)
      org.valid?
      expect(org.errors[:name]).to include(I18n.t("validations.organisation.name_not_unique"))
    end

    context "with parent/child associations", :aggregate_failures do
      let!(:child_organisation) { create(:organisation, name: "MHCLG Child") }
      let!(:grandchild_organisation) { create(:organisation, name: "MHCLG Grandchild") }

      before do
        create(
          :organisation_relationship,
          child_organisation:,
          parent_organisation: organisation,
        )

        create(
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
      let!(:child_organisation) { create(:organisation, name: "MHCLG Child") }
      let!(:grandchild_organisation) { create(:organisation, name: "MHCLG Grandchild") }

      before do
        create(
          :organisation_relationship,
          child_organisation:,
          parent_organisation: organisation,
        )

        create(
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
      let!(:child_organisation) { create(:organisation, name: "MHCLG Child") }
      let!(:grandchild_organisation) { create(:organisation, name: "MHCLG Grandchild") }

      before do
        create(
          :organisation_relationship,
          child_organisation:,
          parent_organisation: organisation,
        )

        create(
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
        create(:data_protection_confirmation, organisation:, confirmed: false, created_at: Time.utc(2018, 0o6, 0o5, 10, 36, 49))
        create(:data_protection_confirmation, organisation:, created_at: Time.utc(2019, 0o6, 0o5, 10, 36, 49))
      end

      it "takes the most recently created" do
        expect(organisation.data_protection_confirmed?).to be true
      end
    end

    context "with associated rent periods" do
      let(:organisation) { create(:organisation) }
      let(:period_1_label) { "Every minute" }
      let(:period_2_label) { "Every decade" }
      let(:period_3_label) { "Every century" }
      let(:period_4_label) { "Every millennium" }
      let(:fake_rent_periods) do
        {
          "1" => { "value" => period_1_label },
          "2" => { "value" => period_2_label },
          "3" => { "value" => period_3_label },
          "4" => { "value" => period_4_label },
        }
      end

      before do
        [4, 2, 1].each do |rent_period|
          create(:organisation_rent_period, organisation:, rent_period:)
        end
        allow(RentPeriod).to receive(:rent_period_mappings).and_return(fake_rent_periods)
      end

      context "when the org does not use all rent periods" do
        it "#rent_periods returns the correct ids" do
          expect(organisation.rent_periods).to match_array([4, 2, 1])
        end

        it "#rent_period_labels returns the correct labels in order" do
          expect(organisation.rent_period_labels).to eq [period_1_label, period_2_label, period_4_label]
        end

        context "and has organisation rent periods associated for rent periods that no longer appear in the form" do
          before do
            create(:organisation_rent_period, organisation:, rent_period: 6)
          end

          it "#rent_period_labels returns the correct labels" do
            expect(organisation.rent_period_labels).to eq [period_1_label, period_2_label, period_4_label]
          end
        end
      end

      context "when the org uses all rent periods" do
        before do
          create(:organisation_rent_period, organisation:, rent_period: 3)
        end

        it "#rent_periods returns the correct ids" do
          expect(organisation.rent_periods).to match_array([4, 2, 1, 3])
        end

        it "#rent_period_labels returns All" do
          expect(organisation.rent_period_labels).to eq %w[All]
        end

        context "and has organisation rent periods associated for rent periods that no longer appear in the form" do
          before do
            create(:organisation_rent_period, organisation:, rent_period: 6)
          end

          it "#rent_period_labels returns All" do
            expect(organisation.rent_period_labels).to eq %w[All]
          end
        end
      end
    end

    context "with lettings logs" do
      let(:other_organisation) { create(:organisation) }
      let!(:owned_lettings_log) do
        create(
          :lettings_log,
          :completed,
          managing_organisation: other_organisation,
          assigned_to: user,
        )
      end
      let!(:managed_lettings_log) do
        create(
          :lettings_log,
          assigned_to: user,
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
    end
  end

  describe "paper trail" do
    let(:organisation) { create(:organisation, name: "MHCLG") }

    it "creates a record of changes to a log" do
      expect { organisation.update!(name: "new test name") }.to change(organisation.versions, :count).by(1)
    end

    it "allows lettings logs to be restored to a previous version" do
      organisation.update!(name: "new test name")
      expect(organisation.paper_trail.previous_version.name).to eq("MHCLG")
    end
  end

  describe "delete cascade" do
    context "when the organisation is deleted" do
      let!(:organisation) { create(:organisation) }
      let!(:user) { create(:user, :support, last_sign_in_at: Time.zone.now, organisation:) }
      let!(:scheme_to_delete) { create(:scheme, owning_organisation: user.organisation) }
      let!(:log_to_delete) { create(:lettings_log, owning_organisation: user.organisation) }
      let!(:sales_log_to_delete) { create(:sales_log, owning_organisation: user.organisation) }

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
      create(:organisation, name: "Joe Bloggs", active: false)
      create(:organisation, name: "Tom Smith", active: true)
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

    context "when searching by active" do
      it "returns only active records" do
        results = described_class.filter_by_active
        expect(results.count).to eq(1)
        expect(results[0].name).to eq("Tom Smith")
      end
    end
  end

  describe "status" do
    let!(:organisation) { create(:organisation) }

    it "returns inactive when organisation inactive" do
      organisation.active = false

      expect(organisation.status).to be(:deactivated)
    end

    it "returns active when organisation active" do
      organisation.active = true

      expect(organisation.status).to be(:active)
    end

    it "returns merged when organisation merged in the past" do
      organisation.merge_date = 1.month.ago

      expect(organisation.status).to be(:merged)
    end

    it "does not return merged when organisation merges in the future" do
      organisation.active = true
      organisation.merge_date = Time.zone.now + 1.month

      expect(organisation.status).to be(:active)
    end
  end

  describe "discard" do
    let(:organisation) { create(:organisation) }
    let!(:user) { create(:user, organisation:) }
    let!(:scheme) { create(:scheme, owning_organisation: organisation) }

    context "when merged organisation is discarded" do
      before do
        organisation.merge_date = Time.zone.yesterday
        organisation.absorbing_organisation_id = create(:organisation).id
        organisation.save!
      end

      it "discards all of the organisation resources" do
        organisation.discard!
        expect(organisation.status).to eq(:deleted)
        expect(user.reload.status).to eq(:deleted)
        expect(scheme.reload.status).to eq(:deleted)
      end
    end
  end
end

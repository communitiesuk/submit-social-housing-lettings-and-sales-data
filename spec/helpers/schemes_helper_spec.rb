require "rails_helper"

RSpec.describe SchemesHelper do
  describe "Active periods" do
    let(:scheme) { FactoryBot.create(:scheme, created_at: Time.zone.today) }

    before do
      allow(Time).to receive(:now).and_return(Time.zone.local(2023, 1, 10))
    end

    it "returns one active period without to date" do
      expect(scheme_active_periods(scheme).count).to eq(1)
      expect(scheme_active_periods(scheme).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: nil)
    end

    it "ignores reactivations that were deactivated on the same day" do
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 4), scheme:)
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 4), scheme:)
      scheme.reload

      expect(scheme_active_periods(scheme).count).to eq(1)
      expect(scheme_active_periods(scheme).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 5, 5))
    end

    it "returns sequential non reactivated active periods" do
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 4), scheme:)
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 7, 6), scheme:)
      scheme.reload

      expect(scheme_active_periods(scheme).count).to eq(2)
      expect(scheme_active_periods(scheme).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 5, 5))
      expect(scheme_active_periods(scheme).second).to have_attributes(from: Time.zone.local(2022, 6, 4), to: Time.zone.local(2022, 7, 6))
    end

    it "returns sequential reactivated active periods" do
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 4), scheme:)
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 7, 6), reactivation_date: Time.zone.local(2022, 8, 5), scheme:)
      scheme.reload
      expect(scheme_active_periods(scheme).count).to eq(3)
      expect(scheme_active_periods(scheme).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 5, 5))
      expect(scheme_active_periods(scheme).second).to have_attributes(from: Time.zone.local(2022, 6, 4), to: Time.zone.local(2022, 7, 6))
      expect(scheme_active_periods(scheme).third).to have_attributes(from: Time.zone.local(2022, 8, 5), to: nil)
    end

    it "returns non sequential non reactivated active periods" do
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 7, 6), reactivation_date: Time.zone.local(2022, 8, 5), scheme:)
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: nil, scheme:)
      scheme.reload

      expect(scheme_active_periods(scheme).count).to eq(2)
      expect(scheme_active_periods(scheme).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 5, 5))
      expect(scheme_active_periods(scheme).second).to have_attributes(from: Time.zone.local(2022, 8, 5), to: nil)
    end

    it "returns non sequential reactivated active periods" do
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 7, 6), reactivation_date: Time.zone.local(2022, 8, 5), scheme:)
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 4), scheme:)
      scheme.reload
      expect(scheme_active_periods(scheme).count).to eq(3)
      expect(scheme_active_periods(scheme).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 5, 5))
      expect(scheme_active_periods(scheme).second).to have_attributes(from: Time.zone.local(2022, 6, 4), to: Time.zone.local(2022, 7, 6))
      expect(scheme_active_periods(scheme).third).to have_attributes(from: Time.zone.local(2022, 8, 5), to: nil)
    end

    it "returns correct active periods when reactivation happends during a deactivated period" do
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 11, 11), scheme:)
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 4, 6), reactivation_date: Time.zone.local(2022, 7, 7), scheme:)
      scheme.reload

      expect(scheme_active_periods(scheme).count).to eq(2)
      expect(scheme_active_periods(scheme).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 4, 6))
      expect(scheme_active_periods(scheme).second).to have_attributes(from: Time.zone.local(2022, 11, 11), to: nil)
    end

    it "returns correct active periods when a full deactivation period happens during another deactivation period" do
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 5, 5), reactivation_date: Time.zone.local(2022, 6, 11), scheme:)
      FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 4, 6), reactivation_date: Time.zone.local(2022, 7, 7), scheme:)
      scheme.reload

      expect(scheme_active_periods(scheme).count).to eq(2)
      expect(scheme_active_periods(scheme).first).to have_attributes(from: Time.zone.local(2022, 4, 1), to: Time.zone.local(2022, 4, 6))
      expect(scheme_active_periods(scheme).second).to have_attributes(from: Time.zone.local(2022, 7, 7), to: nil)
    end
  end

  include TagHelper
  describe "edit_scheme_text" do
    let(:parent_organisation) { FactoryBot.create(:organisation, name: "Parent") }
    let(:child_organisation) { FactoryBot.create(:organisation, name: "Child") }

    let(:scheme) { FactoryBot.create(:scheme, owning_organisation: parent_organisation) }
    let(:data_coordinator) { FactoryBot.create(:user, :data_coordinator, organisation: child_organisation) }
    let(:data_provider) { FactoryBot.create(:user, :data_provider, organisation: child_organisation) }

    before do
      create(:organisation_relationship, child_organisation:, parent_organisation:)
    end

    context "with data coordinator user" do
      it "returns correct edit scheme text for a parent organisation scheme" do
        expect(edit_scheme_text(scheme, data_coordinator)).to include("This scheme belongs to your stock owner Parent.")
      end

      it "returns nil when viewing your organisation scheme" do
        data_coordinator.update!(organisation: parent_organisation)
        expect(edit_scheme_text(scheme, data_coordinator)).to be_nil
      end
    end

    context "with data provider user" do
      it "returns correct edit scheme text for a parent organisation scheme" do
        expect(edit_scheme_text(scheme, data_provider)).to include("If you think this scheme should be updated, ask a data coordinator to make the changes. Find your data coordinators on the ")
      end

      it "returns correct edit scheme text for your organisation scheme" do
        data_provider.update!(organisation: parent_organisation)
        expect(edit_scheme_text(scheme, data_provider)).to include("If you think this scheme should be updated, ask a data coordinator to make the changes. Find your data coordinators on the ")
      end
    end
  end
end

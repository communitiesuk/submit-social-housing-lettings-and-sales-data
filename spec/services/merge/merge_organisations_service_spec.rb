require "rails_helper"

RSpec.describe Merge::MergeOrganisationsService do
  subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids]) }

  let(:absorbing_organisation) {    create(:organisation, holds_own_stock: false) }
  let(:absorbing_organisation_user) { create(:user, organisation: absorbing_organisation) }

  describe "#call" do
    context "when merging a single organisation into an existing organisation" do
      let(:merging_organisation) { create(:organisation, holds_own_stock: true) }

      let(:merging_organisation_ids) { [merging_organisation.id] }
      let!(:merging_organisation_user) { create(:user, organisation: merging_organisation) }

      it "moves the users from merging organisation to absorbing organisation" do
        merge_organisations_service.call

        merging_organisation_user.reload
        expect(merging_organisation_user.organisation).to eq(absorbing_organisation)
      end

      xit "sets merge date on merged organisation" do
        merge_organisations_service.call

        expect(merging_organisation.merge_date).to eq(Time.zone.today)
      end

      it "combines organisation data" do
        merge_organisations_service.call

        absorbing_organisation.reload
        expect(absorbing_organisation.holds_own_stock).to eq(true)
      end

      context "and merging organisation rent periods" do
        before do
          OrganisationRentPeriod.create!(organisation: absorbing_organisation, rent_period: 1)
          OrganisationRentPeriod.create!(organisation: absorbing_organisation, rent_period: 3)
          OrganisationRentPeriod.create!(organisation: merging_organisation, rent_period: 1)
          OrganisationRentPeriod.create!(organisation: merging_organisation, rent_period: 2)
          merge_organisations_service.call
        end

        it "combines organisation rent periods" do
          absorbing_organisation.reload
          expect(absorbing_organisation.rent_periods.count).to eq(3)
          expect(absorbing_organisation.rent_periods).to include(1)
          expect(absorbing_organisation.rent_periods).to include(2)
          expect(absorbing_organisation.rent_periods).to include(3)
        end
      end

      context "and merging organisation relationships" do
        let(:other_organisation) { create(:organisation) }
        let!(:merging_organisation_relationship) { create(:organisation_relationship, parent_organisation: merging_organisation) }
        let!(:absorbing_organisation_relationship) { create(:organisation_relationship, parent_organisation: absorbing_organisation) }

        before do
          create(:organisation_relationship, parent_organisation: absorbing_organisation, child_organisation: merging_organisation)
          create(:organisation_relationship, parent_organisation: merging_organisation, child_organisation: other_organisation)
          create(:organisation_relationship, parent_organisation: absorbing_organisation, child_organisation: other_organisation)
        end

        it "combines organisation relationships" do
          merge_organisations_service.call

          absorbing_organisation.reload
          expect(absorbing_organisation.child_organisations).to include(other_organisation)
          expect(absorbing_organisation.child_organisations).to include(absorbing_organisation_relationship.child_organisation)
          expect(absorbing_organisation.child_organisations).to include(merging_organisation_relationship.child_organisation)
          expect(absorbing_organisation.child_organisations).not_to include(merging_organisation)
          expect(absorbing_organisation.parent_organisations.count).to eq(0)
          expect(absorbing_organisation.child_organisations.count).to eq(3)
        end
      end

      context "and merging organisation schemes and locations" do
        let!(:scheme) { create(:scheme, owning_organisation: merging_organisation) }
        let!(:location) { create(:location, scheme:) }
        let!(:deactivated_location) { create(:location, scheme:) }
        let!(:deactivated_scheme) { create(:scheme, owning_organisation: merging_organisation) }
        let!(:owned_lettings_log) { create(:lettings_log, :sh, scheme:, location:, startdate: Time.zone.tomorrow, owning_organisation: merging_organisation) }
        let!(:owned_lettings_log_no_location) { create(:lettings_log, :sh, scheme:, startdate: Time.zone.tomorrow, owning_organisation: merging_organisation) }

        before do
          create(:location, scheme:)
          create(:location, scheme: deactivated_scheme)
          create(:scheme_deactivation_period, scheme: deactivated_scheme, deactivation_date: Time.zone.today - 1.month)
          create(:location_deactivation_period, location: deactivated_location, deactivation_date: Time.zone.today - 1.month)
          create(:lettings_log, scheme:, location:, startdate: Time.zone.yesterday)
          create(:lettings_log, startdate: Time.zone.tomorrow, managing_organisation: merging_organisation)
        end

        it "combines organisation relationships" do
          merge_organisations_service.call

          absorbing_organisation.reload
          expect(absorbing_organisation.owned_schemes.count).to eq(1)
          expect(absorbing_organisation.owned_schemes.first.service_name).to eq(scheme.service_name)
          expect(absorbing_organisation.owned_schemes.first.locations.count).to eq(2)
          expect(absorbing_organisation.owned_schemes.first.locations.first.postcode).to eq(location.postcode)
          expect(scheme.scheme_deactivation_periods.count).to eq(1)
          expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today)
        end

        it "moves relevant logs and assigns the new scheme" do
          merge_organisations_service.call

          absorbing_organisation.reload
          expect(absorbing_organisation.owned_lettings_logs.count).to eq(2)
          expect(absorbing_organisation.managed_lettings_logs.count).to eq(1)
          expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).scheme).to eq(absorbing_organisation.owned_schemes.first)
          expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).location).to eq(absorbing_organisation.owned_schemes.first.locations.first)
          expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).scheme).to eq(absorbing_organisation.owned_schemes.first)
          expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).location).to eq(nil)
        end
      end

      context "and merging sales logs" do
        let!(:sales_log) { create(:sales_log, saledate: Time.zone.tomorrow, owning_organisation: merging_organisation) }

        before do
          create(:sales_log, saledate: Time.zone.yesterday, owning_organisation: merging_organisation)
        end

        it "moves relevant logs" do
          merge_organisations_service.call

          absorbing_organisation.reload
          expect(absorbing_organisation.owned_sales_logs.count).to eq(1)
          expect(absorbing_organisation.owned_sales_logs.first).to eq(sales_log)
        end
      end
    end
  end
end

require "rails_helper"

RSpec.describe Merge::MergeOrganisationsService do
  subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids]) }

  let(:absorbing_organisation) do
    create(:organisation,
           holds_own_stock: false,
           choice_based_lettings: false,
           common_housing_register: true,
           choice_allocation_policy: true)
  end
  let(:absorbing_organisation_user) { create(:user, organisation: absorbing_organisation) }

  describe "#call" do
    context "when merging a single organisation into an existing organisation" do
      let(:other_organisation) { create(:organisation) }
      let(:merging_organisation) do
        create(:organisation,
               holds_own_stock: true,
               choice_based_lettings: false,
               common_housing_register: false,
               choice_allocation_policy: true)
      end

      let(:merging_organisation_ids) { [merging_organisation.id] }
      let!(:merging_organisation_user) { create(:user, organisation: merging_organisation) }
      let!(:merging_organisation_relationship) { create(:organisation_relationship, parent_organisation: merging_organisation) }
      let!(:absorbing_organisation_relationship) { create(:organisation_relationship, parent_organisation: absorbing_organisation) }
      let!(:absorbing_and_merging_organisation_relationship) { create(:organisation_relationship, parent_organisation: absorbing_organisation, child_organisation: merging_organisation) }
      let!(:duplicate_merging_organisation_relationship) { create(:organisation_relationship, parent_organisation: merging_organisation, child_organisation: other_organisation) }
      let!(:duplicate_absorbing_organisation_relationship) { create(:organisation_relationship, parent_organisation: absorbing_organisation, child_organisation: other_organisation) }

      before do
        OrganisationRentPeriod.create!(organisation: absorbing_organisation, rent_period: 1)
        OrganisationRentPeriod.create!(organisation: absorbing_organisation, rent_period: 3)
        OrganisationRentPeriod.create!(organisation: merging_organisation, rent_period: 1)
        OrganisationRentPeriod.create!(organisation: merging_organisation, rent_period: 2)
        merge_organisations_service.call
      end

      it "moves the users from merging organisation to absorbing organisation" do
        merging_organisation_user.reload
        expect(merging_organisation_user.organisation).to eq(absorbing_organisation)
      end

      xit "sets merge date on merged organisation" do
        expect(merging_organisation.merge_date).to eq(Time.zone.today)
      end

      it "combines organisation data" do
        absorbing_organisation.reload
        expect(absorbing_organisation.holds_own_stock).to eq(true)
        expect(absorbing_organisation.choice_based_lettings).to eq(false)
        expect(absorbing_organisation.common_housing_register).to eq(true)
        expect(absorbing_organisation.choice_allocation_policy).to eq(true)
        #   expect(absorbing_organisation.cbl_proportion_percentage).to eq(0)
        #   expect(absorbing_organisation.enter_affordable_logs).to eq(true)
        #   expect(absorbing_organisation.owns_affordable_logs).to eq(true)
        #   expect(absorbing_organisation.general_needs_units).to eq(2)
        #   expect(absorbing_organisation.supported_housing_units).to eq(2)
        #   expect(absorbing_organisation.unspecified_units).to eq(2)
      end

      it "combines organisation rent periods" do
        absorbing_organisation.reload
        expect(absorbing_organisation.rent_periods.count).to eq(3)
        expect(absorbing_organisation.rent_periods).to include(1)
        expect(absorbing_organisation.rent_periods).to include(2)
        expect(absorbing_organisation.rent_periods).to include(3)
      end

      it "combines organisation relationships" do
        absorbing_organisation.reload
        expect(absorbing_organisation.child_organisations).to include(other_organisation)
        expect(absorbing_organisation.child_organisations).to include(absorbing_organisation_relationship.child_organisation)
        expect(absorbing_organisation.child_organisations).to include(merging_organisation_relationship.child_organisation)
        expect(absorbing_organisation.child_organisations).not_to include(merging_organisation)
        expect(absorbing_organisation.parent_organisations.count).to eq(0)
        expect(absorbing_organisation.child_organisations.count).to eq(3)
      end
    end
  end
end

require "rails_helper"

RSpec.describe Merge::MergeOrganisationsService do
  describe "#call" do
    context "when merging a single organisation into an existing organisation" do
      subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: nil) }

      let(:absorbing_organisation) { create(:organisation, holds_own_stock: false) }
      let(:absorbing_organisation_user) { create(:user, organisation: absorbing_organisation) }

      let(:merging_organisation) { create(:organisation, holds_own_stock: true, name: "fake org") }

      let(:merging_organisation_ids) { [merging_organisation.id] }
      let!(:merging_organisation_user) { create(:user, organisation: merging_organisation, name: "fake name", email: "fake@email.com") }

      it "moves the users from merging organisation to absorbing organisation" do
        expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
        expect(Rails.logger).to receive(:info).with("\tDanny Rojas (#{merging_organisation.data_protection_officers.first.email})")
        expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
        expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
        merge_organisations_service.call

        merging_organisation_user.reload
        expect(merging_organisation_user.organisation).to eq(absorbing_organisation)
      end

      it "sets merge date on merged organisation" do
        merge_organisations_service.call

        merging_organisation.reload
        expect(merging_organisation.merge_date.to_date).to eq(Time.zone.today)
        expect(merging_organisation.absorbing_organisation_id).to eq(absorbing_organisation.id)
      end

      it "combines organisation data" do
        merge_organisations_service.call

        absorbing_organisation.reload
        expect(absorbing_organisation.holds_own_stock).to eq(true)
      end

      it "rolls back if there's an error" do
        allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
        allow(Organisation).to receive(:find).with(absorbing_organisation.id).and_return(absorbing_organisation)
        allow(absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
        merge_organisations_service.call

        absorbing_organisation.reload
        merging_organisation.reload
        expect(absorbing_organisation.holds_own_stock).to eq(false)
        expect(merging_organisation.merge_date).to eq(nil)
        expect(merging_organisation.absorbing_organisation_id).to eq(nil)
        expect(merging_organisation_user.organisation).to eq(merging_organisation)
      end

      it "does not set available_from for absorbing organisation" do
        merge_organisations_service.call

        absorbing_organisation.reload
        expect(absorbing_organisation.available_from).to be_nil
      end

      context "and merging organisation rent periods" do
        before do
          OrganisationRentPeriod.create!(organisation: absorbing_organisation, rent_period: 1)
          OrganisationRentPeriod.create!(organisation: absorbing_organisation, rent_period: 3)
          OrganisationRentPeriod.create!(organisation: merging_organisation, rent_period: 1)
          OrganisationRentPeriod.create!(organisation: merging_organisation, rent_period: 2)
        end

        it "combines organisation rent periods" do
          expect(absorbing_organisation.rent_periods.count).to eq(2)
          merge_organisations_service.call

          absorbing_organisation.reload
          expect(absorbing_organisation.rent_periods.count).to eq(3)
          expect(absorbing_organisation.rent_periods).to include(1)
          expect(absorbing_organisation.rent_periods).to include(2)
          expect(absorbing_organisation.rent_periods).to include(3)
        end

        it "rolls back if there's an error" do
          allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
          allow(Organisation).to receive(:find).with(absorbing_organisation.id).and_return(absorbing_organisation)
          allow(absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
          merge_organisations_service.call

          absorbing_organisation.reload
          merging_organisation.reload
          expect(absorbing_organisation.rent_periods.count).to eq(2)
          expect(merging_organisation.rent_periods.count).to eq(2)
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

        it "rolls back if there's an error" do
          allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
          allow(Organisation).to receive(:find).with(absorbing_organisation.id).and_return(absorbing_organisation)
          allow(absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
          merge_organisations_service.call

          absorbing_organisation.reload
          expect(absorbing_organisation.child_organisations.count).to eq(3)
          expect(absorbing_organisation.child_organisations).to include(other_organisation)
          expect(absorbing_organisation.child_organisations).to include(merging_organisation)
          expect(absorbing_organisation.child_organisations).to include(absorbing_organisation_relationship.child_organisation)
        end
      end

      context "and merging organisation schemes and locations" do
        let!(:scheme) { create(:scheme, owning_organisation: merging_organisation, old_id: "scheme_old_id", old_visible_id: "scheme_old_visible_id") }
        let!(:location) { create(:location, scheme:, old_id: "location_old_id", old_visible_id: "location_old_visible_id") }
        let!(:deactivated_location) { create(:location, scheme:) }
        let!(:deactivated_scheme) { create(:scheme, owning_organisation: merging_organisation) }
        let!(:owned_lettings_log) { create(:lettings_log, :sh, scheme:, location:, startdate: Time.zone.tomorrow, owning_organisation: merging_organisation) }
        let!(:owned_lettings_log_no_location) { create(:lettings_log, :sh, scheme:, startdate: Time.zone.tomorrow, owning_organisation: merging_organisation) }

        before do
          create(:location, scheme: deactivated_scheme)
          create(:scheme_deactivation_period, scheme: deactivated_scheme, deactivation_date: Time.zone.today - 1.month)
          create(:location_deactivation_period, location: deactivated_location, deactivation_date: Time.zone.today - 1.month)
          create(:lettings_log, scheme:, location:, startdate: Time.zone.yesterday)
          create(:lettings_log, startdate: Time.zone.tomorrow, managing_organisation: merging_organisation)
        end

        it "combines organisation schemes and locations" do
          expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
          expect(Rails.logger).to receive(:info).with("\tDanny Rojas (#{merging_organisation.data_protection_officers.first.email})")
          expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
          expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
          expect(Rails.logger).to receive(:info).with(/\t#{scheme.service_name} \(S/)
          merge_organisations_service.call

          absorbing_organisation.reload
          expect(absorbing_organisation.owned_schemes.count).to eq(1)
          expect(absorbing_organisation.owned_schemes.first.service_name).to eq(scheme.service_name)
          expect(absorbing_organisation.owned_schemes.first.old_id).to be_nil
          expect(absorbing_organisation.owned_schemes.first.old_visible_id).to be_nil
          expect(absorbing_organisation.owned_schemes.first.locations.count).to eq(1)
          expect(absorbing_organisation.owned_schemes.first.locations.first.postcode).to eq(location.postcode)
          expect(absorbing_organisation.owned_schemes.first.locations.first.old_id).to be_nil
          expect(absorbing_organisation.owned_schemes.first.locations.first.old_visible_id).to be_nil
          expect(scheme.scheme_deactivation_periods.count).to eq(1)
          expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today)
          expect(scheme.locations.first.location_deactivation_periods.count).to eq(1)
          expect(scheme.locations.first.location_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today)
        end

        it "moves relevant logs and assigns the new scheme" do
          merge_organisations_service.call

          absorbing_organisation.reload
          merging_organisation.reload
          expect(absorbing_organisation.owned_lettings_logs.count).to eq(2)
          expect(absorbing_organisation.managed_lettings_logs.count).to eq(1)
          expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).scheme).to eq(absorbing_organisation.owned_schemes.first)
          expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).location).to eq(absorbing_organisation.owned_schemes.first.locations.first)
          expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).scheme).to eq(absorbing_organisation.owned_schemes.first)
          expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).location).to eq(nil)
        end

        it "rolls back if there's an error" do
          allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
          allow(Organisation).to receive(:find).with(absorbing_organisation.id).and_return(absorbing_organisation)
          allow(absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
          merge_organisations_service.call

          absorbing_organisation.reload
          merging_organisation.reload
          expect(absorbing_organisation.owned_schemes.count).to eq(0)
          expect(scheme.scheme_deactivation_periods.count).to eq(0)
          expect(scheme.locations.first.location_deactivation_periods.count).to eq(0)
          expect(owned_lettings_log.owning_organisation).to eq(merging_organisation)
          expect(owned_lettings_log_no_location.owning_organisation).to eq(merging_organisation)
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
          expect(SalesLog.filter_by_owning_organisation(absorbing_organisation).count).to eq(1)
          expect(SalesLog.filter_by_owning_organisation(absorbing_organisation).first).to eq(sales_log)
        end

        it "rolls back if there's an error" do
          allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
          allow(Organisation).to receive(:find).with(absorbing_organisation.id).and_return(absorbing_organisation)
          allow(absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
          merge_organisations_service.call

          absorbing_organisation.reload
          expect(absorbing_organisation.sales_logs.count).to eq(0)
          expect(sales_log.owning_organisation).to eq(merging_organisation)
        end
      end

      context "and merge date is provided" do
        subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: Time.zone.yesterday) }

        it "sets merge date on merged organisation" do
          merge_organisations_service.call

          merging_organisation.reload
          expect(merging_organisation.merge_date.to_date).to eq(Time.zone.yesterday)
          expect(merging_organisation.absorbing_organisation_id).to eq(absorbing_organisation.id)
        end

        context "and merging sales logs" do
          let!(:sales_log) { create(:sales_log, saledate: Time.zone.today, owning_organisation: merging_organisation) }

          before do
            create(:sales_log, saledate: Time.zone.today - 2.days, owning_organisation: merging_organisation)
          end

          it "moves relevant logs" do
            merge_organisations_service.call

            absorbing_organisation.reload
            expect(SalesLog.filter_by_owning_organisation(absorbing_organisation).count).to eq(1)
            expect(SalesLog.filter_by_owning_organisation(absorbing_organisation).first).to eq(sales_log)
          end

          it "rolls back if there's an error" do
            allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
            allow(Organisation).to receive(:find).with(absorbing_organisation.id).and_return(absorbing_organisation)
            allow(absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
            expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
            merge_organisations_service.call

            absorbing_organisation.reload
            expect(absorbing_organisation.sales_logs.count).to eq(0)
            expect(sales_log.owning_organisation).to eq(merging_organisation)
          end
        end

        context "and merging lettings logs" do
          let(:owning_organisation) { create(:organisation, holds_own_stock: true) }
          let!(:owned_lettings_log) { create(:lettings_log, startdate: Time.zone.today, owning_organisation: merging_organisation, created_by: merging_organisation_user) }
          let!(:managed_lettings_log) { create(:lettings_log, startdate: Time.zone.today) }

          before do
            create(:organisation_relationship) { create(:organisation_relationship, parent_organisation: owning_organisation, child_organisation: merging_organisation) }
            managed_lettings_log.update!(owning_organisation:, managing_organisation: merging_organisation, created_by: merging_organisation_user)
            create(:lettings_log, startdate: Time.zone.today - 2.days, owning_organisation: merging_organisation, created_by: merging_organisation_user)
            create(:lettings_log, startdate: Time.zone.today - 2.days, owning_organisation:, managing_organisation: merging_organisation, created_by: merging_organisation_user)
          end

          it "moves relevant logs" do
            merge_organisations_service.call

            absorbing_organisation.reload
            expect(LettingsLog.filter_by_owning_organisation(absorbing_organisation).count).to eq(1)
            expect(LettingsLog.filter_by_owning_organisation(absorbing_organisation).first).to eq(owned_lettings_log)
            expect(LettingsLog.filter_by_managing_organisation(absorbing_organisation).count).to eq(2)
            expect(LettingsLog.filter_by_managing_organisation(absorbing_organisation)).to include(managed_lettings_log)
            expect(LettingsLog.filter_by_managing_organisation(absorbing_organisation)).to include(owned_lettings_log)
          end

          it "rolls back if there's an error" do
            allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
            allow(Organisation).to receive(:find).with(absorbing_organisation.id).and_return(absorbing_organisation)
            allow(absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
            expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
            merge_organisations_service.call

            absorbing_organisation.reload
            expect(absorbing_organisation.lettings_logs.count).to eq(0)
            expect(owned_lettings_log.owning_organisation).to eq(merging_organisation)
            expect(managed_lettings_log.managing_organisation).to eq(merging_organisation)
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
            create(:location, scheme: deactivated_scheme)
            create(:scheme_deactivation_period, scheme: deactivated_scheme, deactivation_date: Time.zone.today - 1.month)
            create(:location_deactivation_period, location: deactivated_location, deactivation_date: Time.zone.today - 1.month)
            create(:lettings_log, scheme:, location:, startdate: Time.zone.yesterday)
            create(:lettings_log, startdate: Time.zone.tomorrow, managing_organisation: merging_organisation)
          end

          it "combines organisation schemes and locations" do
            expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
            expect(Rails.logger).to receive(:info).with("\tDanny Rojas (#{merging_organisation.data_protection_officers.first.email})")
            expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
            expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
            expect(Rails.logger).to receive(:info).with(/\t#{scheme.service_name} \(S/)
            merge_organisations_service.call

            absorbing_organisation.reload
            expect(absorbing_organisation.owned_schemes.count).to eq(1)
            expect(absorbing_organisation.owned_schemes.first.service_name).to eq(scheme.service_name)
            expect(absorbing_organisation.owned_schemes.first.locations.count).to eq(1)
            expect(absorbing_organisation.owned_schemes.first.locations.first.postcode).to eq(location.postcode)
            expect(scheme.scheme_deactivation_periods.count).to eq(1)
            expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.yesterday)
            expect(scheme.locations.first.location_deactivation_periods.count).to eq(1)
            expect(scheme.locations.first.location_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.yesterday)
          end

          it "moves relevant logs and assigns the new scheme" do
            merge_organisations_service.call

            absorbing_organisation.reload
            merging_organisation.reload
            expect(absorbing_organisation.owned_lettings_logs.count).to eq(2)
            expect(absorbing_organisation.managed_lettings_logs.count).to eq(1)
            expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).scheme).to eq(absorbing_organisation.owned_schemes.first)
            expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).location).to eq(absorbing_organisation.owned_schemes.first.locations.first)
            expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).scheme).to eq(absorbing_organisation.owned_schemes.first)
            expect(absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).location).to eq(nil)
          end

          it "rolls back if there's an error" do
            allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
            allow(Organisation).to receive(:find).with(absorbing_organisation.id).and_return(absorbing_organisation)
            allow(absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
            expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
            merge_organisations_service.call

            absorbing_organisation.reload
            merging_organisation.reload
            expect(absorbing_organisation.owned_schemes.count).to eq(0)
            expect(scheme.scheme_deactivation_periods.count).to eq(0)
            expect(scheme.locations.first.location_deactivation_periods.count).to eq(0)
            expect(owned_lettings_log.owning_organisation).to eq(merging_organisation)
            expect(owned_lettings_log_no_location.owning_organisation).to eq(merging_organisation)
          end
        end

        context "and absorbing_organisation_active_from_merge_date is true" do
          subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: Time.zone.yesterday, absorbing_organisation_active_from_merge_date: true) }

          it "sets available from to merge_date for absorbing organisation" do
            merge_organisations_service.call

            absorbing_organisation.reload
            expect(absorbing_organisation.available_from.to_date).to eq(Time.zone.yesterday)
          end
        end
      end

      context "and absorbing_organisation_active_from_merge_date is true" do
        subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], absorbing_organisation_active_from_merge_date: true) }

        it "sets available from to merge_date (today) for absorbing organisation" do
          merge_organisations_service.call

          absorbing_organisation.reload
          expect(absorbing_organisation.available_from.to_date).to eq(Time.zone.today)
        end
      end
    end

    context "when merging a multiple organisations into an existing organisation" do
      subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: nil) }

      let(:absorbing_organisation) { create(:organisation, holds_own_stock: false) }
      let(:absorbing_organisation_user) { create(:user, organisation: absorbing_organisation) }

      let(:merging_organisation) { create(:organisation, holds_own_stock: true, name: "fake org") }
      let(:merging_organisation_too) { create(:organisation, holds_own_stock: true, name: "second org") }

      let(:merging_organisation_ids) { [merging_organisation.id, merging_organisation_too.id] }
      let!(:merging_organisation_user) { create(:user, organisation: merging_organisation, name: "fake name", email: "fake@email.com") }

      before do
        create_list(:user, 5, organisation: merging_organisation_too)
      end

      it "moves the users from merging organisations to absorbing organisation" do
        expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
        expect(Rails.logger).to receive(:info).with("\tDanny Rojas (#{merging_organisation.data_protection_officers.first.email})")
        expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
        expect(Rails.logger).to receive(:info).with("Merged users from second org:")
        expect(Rails.logger).to receive(:info).with(/\tDanny Rojas/).exactly(6).times
        expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
        expect(Rails.logger).to receive(:info).with("New schemes from second org:")
        merge_organisations_service.call

        merging_organisation_user.reload
        expect(merging_organisation_user.organisation).to eq(absorbing_organisation)
      end

      it "sets merge date and absorbing organisation on merged organisations" do
        merge_organisations_service.call

        merging_organisation.reload
        merging_organisation_too.reload
        expect(merging_organisation.merge_date.to_date).to eq(Time.zone.today)
        expect(merging_organisation.absorbing_organisation_id).to eq(absorbing_organisation.id)
        expect(merging_organisation_too.merge_date.to_date).to eq(Time.zone.today)
        expect(merging_organisation_too.absorbing_organisation_id).to eq(absorbing_organisation.id)
      end

      it "combines organisation data" do
        merge_organisations_service.call

        absorbing_organisation.reload
        expect(absorbing_organisation.holds_own_stock).to eq(true)
      end

      it "rolls back if there's an error" do
        allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
        allow(Organisation).to receive(:find).with(absorbing_organisation.id).and_return(absorbing_organisation)
        allow(absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
        merge_organisations_service.call

        absorbing_organisation.reload
        merging_organisation.reload
        expect(absorbing_organisation.holds_own_stock).to eq(false)
        expect(merging_organisation.merge_date).to eq(nil)
        expect(merging_organisation.absorbing_organisation_id).to eq(nil)
        expect(merging_organisation_user.organisation).to eq(merging_organisation)
      end

      context "and merging organisation relationships" do
        let(:other_organisation) { create(:organisation) }
        let!(:merging_organisation_relationship) { create(:organisation_relationship, parent_organisation: merging_organisation) }
        let!(:absorbing_organisation_relationship) { create(:organisation_relationship, parent_organisation: absorbing_organisation) }

        before do
          create(:organisation_relationship, parent_organisation: merging_organisation, child_organisation: absorbing_organisation)
          create(:organisation_relationship, parent_organisation: merging_organisation, child_organisation: other_organisation)
          create(:organisation_relationship, parent_organisation: absorbing_organisation, child_organisation: other_organisation)
          create(:organisation_relationship, parent_organisation: merging_organisation, child_organisation: merging_organisation_too)
        end

        it "combines organisation relationships" do
          merge_organisations_service.call

          absorbing_organisation.reload
          expect(absorbing_organisation.child_organisations).to include(other_organisation)
          expect(absorbing_organisation.child_organisations).to include(absorbing_organisation_relationship.child_organisation)
          expect(absorbing_organisation.child_organisations).to include(merging_organisation_relationship.child_organisation)
          expect(absorbing_organisation.child_organisations).not_to include(merging_organisation)
          expect(absorbing_organisation.parent_organisations).not_to include(merging_organisation)
          expect(absorbing_organisation.child_organisations).not_to include(merging_organisation_too)
          expect(absorbing_organisation.parent_organisations).not_to include(merging_organisation_too)
          expect(absorbing_organisation.parent_organisations.count).to eq(0)
          expect(absorbing_organisation.child_organisations.count).to eq(3)
        end

        it "rolls back if there's an error" do
          allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
          allow(Organisation).to receive(:find).with(absorbing_organisation.id).and_return(absorbing_organisation)
          allow(absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
          merge_organisations_service.call

          absorbing_organisation.reload
          merging_organisation.reload
          expect(absorbing_organisation.child_organisations.count).to eq(2)
          expect(absorbing_organisation.parent_organisations.count).to eq(1)
          expect(absorbing_organisation.child_organisations).to include(other_organisation)
          expect(absorbing_organisation.parent_organisations).to include(merging_organisation)
          expect(absorbing_organisation.child_organisations).to include(absorbing_organisation_relationship.child_organisation)
        end
      end

      context "and merge date is provided" do
        subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: Time.zone.yesterday) }

        it "sets merge date and absorbing organisation on merged organisations" do
          merge_organisations_service.call

          merging_organisation.reload
          merging_organisation_too.reload
          expect(merging_organisation.merge_date.to_date).to eq(Time.zone.yesterday)
          expect(merging_organisation.absorbing_organisation_id).to eq(absorbing_organisation.id)
          expect(merging_organisation_too.merge_date.to_date).to eq(Time.zone.yesterday)
          expect(merging_organisation_too.absorbing_organisation_id).to eq(absorbing_organisation.id)
        end
      end
    end

    context "when merging a single organisation into a new organisation" do
      subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: new_absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: nil) }

      let(:new_absorbing_organisation) { create(:organisation, :without_dpc, holds_own_stock: false) }
      let(:new_absorbing_organisation_user) { create(:user, organisation: new_absorbing_organisation) }

      let(:merging_organisation) { create(:organisation, holds_own_stock: true, name: "fake org") }

      let(:merging_organisation_ids) { [merging_organisation.id] }
      let!(:merging_organisation_user) { create(:user, organisation: merging_organisation, name: "fake name", email: "fake@email.com") }

      it "moves the users from merging organisation to absorbing organisation" do
        expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
        expect(Rails.logger).to receive(:info).with("\tDanny Rojas (#{merging_organisation.data_protection_officers.first.email})")
        expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
        expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
        merge_organisations_service.call

        merging_organisation_user.reload
        expect(merging_organisation_user.organisation).to eq(new_absorbing_organisation)
      end

      it "sets merge date on merged organisation" do
        merge_organisations_service.call

        merging_organisation.reload
        expect(merging_organisation.merge_date.to_date).to eq(Time.zone.today)
        expect(merging_organisation.absorbing_organisation_id).to eq(new_absorbing_organisation.id)
      end

      it "combines organisation data" do
        merge_organisations_service.call

        new_absorbing_organisation.reload
        expect(new_absorbing_organisation.holds_own_stock).to eq(true)
      end

      it "rolls back if there's an error" do
        allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
        allow(Organisation).to receive(:find).with(new_absorbing_organisation.id).and_return(new_absorbing_organisation)
        allow(new_absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
        merge_organisations_service.call

        new_absorbing_organisation.reload
        merging_organisation.reload
        expect(new_absorbing_organisation.holds_own_stock).to eq(false)
        expect(merging_organisation.merge_date).to eq(nil)
        expect(merging_organisation.absorbing_organisation_id).to eq(nil)
        expect(merging_organisation_user.organisation).to eq(merging_organisation)
      end

      it "does not set available_from for absorbing organisation" do
        merge_organisations_service.call

        new_absorbing_organisation.reload
        expect(new_absorbing_organisation.available_from).to be_nil
      end

      context "and merging organisation rent periods" do
        before do
          OrganisationRentPeriod.create!(organisation: new_absorbing_organisation, rent_period: 1)
          OrganisationRentPeriod.create!(organisation: new_absorbing_organisation, rent_period: 3)
          OrganisationRentPeriod.create!(organisation: merging_organisation, rent_period: 1)
          OrganisationRentPeriod.create!(organisation: merging_organisation, rent_period: 2)
        end

        it "combines organisation rent periods" do
          expect(new_absorbing_organisation.rent_periods.count).to eq(2)
          merge_organisations_service.call

          new_absorbing_organisation.reload
          expect(new_absorbing_organisation.rent_periods.count).to eq(3)
          expect(new_absorbing_organisation.rent_periods).to include(1)
          expect(new_absorbing_organisation.rent_periods).to include(2)
          expect(new_absorbing_organisation.rent_periods).to include(3)
        end

        it "rolls back if there's an error" do
          allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
          allow(Organisation).to receive(:find).with(new_absorbing_organisation.id).and_return(new_absorbing_organisation)
          allow(new_absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
          merge_organisations_service.call

          new_absorbing_organisation.reload
          merging_organisation.reload
          expect(new_absorbing_organisation.rent_periods.count).to eq(2)
          expect(merging_organisation.rent_periods.count).to eq(2)
        end
      end

      context "and merging organisation relationships" do
        let(:other_organisation) { create(:organisation) }
        let!(:merging_organisation_relationship) { create(:organisation_relationship, parent_organisation: merging_organisation) }
        let!(:new_absorbing_organisation_relationship) { create(:organisation_relationship, parent_organisation: new_absorbing_organisation) }

        before do
          create(:organisation_relationship, parent_organisation: new_absorbing_organisation, child_organisation: merging_organisation)
          create(:organisation_relationship, parent_organisation: merging_organisation, child_organisation: other_organisation)
          create(:organisation_relationship, parent_organisation: new_absorbing_organisation, child_organisation: other_organisation)
        end

        it "combines organisation relationships" do
          merge_organisations_service.call

          new_absorbing_organisation.reload
          expect(new_absorbing_organisation.child_organisations).to include(other_organisation)
          expect(new_absorbing_organisation.child_organisations).to include(new_absorbing_organisation_relationship.child_organisation)
          expect(new_absorbing_organisation.child_organisations).to include(merging_organisation_relationship.child_organisation)
          expect(new_absorbing_organisation.child_organisations).not_to include(merging_organisation)
          expect(new_absorbing_organisation.parent_organisations.count).to eq(0)
          expect(new_absorbing_organisation.child_organisations.count).to eq(3)
        end

        it "rolls back if there's an error" do
          allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
          allow(Organisation).to receive(:find).with(new_absorbing_organisation.id).and_return(new_absorbing_organisation)
          allow(new_absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
          merge_organisations_service.call

          new_absorbing_organisation.reload
          expect(new_absorbing_organisation.child_organisations.count).to eq(3)
          expect(new_absorbing_organisation.child_organisations).to include(other_organisation)
          expect(new_absorbing_organisation.child_organisations).to include(merging_organisation)
          expect(new_absorbing_organisation.child_organisations).to include(new_absorbing_organisation_relationship.child_organisation)
        end
      end

      context "and merging organisation schemes and locations" do
        let!(:scheme) { create(:scheme, owning_organisation: merging_organisation, old_id: "scheme_old_id", old_visible_id: "scheme_old_visible_id") }
        let!(:location) { create(:location, scheme:, old_id: "location_old_id", old_visible_id: "location_old_visible_id") }
        let!(:deactivated_location) { create(:location, scheme:) }
        let!(:deactivated_scheme) { create(:scheme, owning_organisation: merging_organisation) }
        let!(:owned_lettings_log) { create(:lettings_log, :sh, scheme:, location:, startdate: Time.zone.tomorrow, owning_organisation: merging_organisation) }
        let!(:owned_lettings_log_no_location) { create(:lettings_log, :sh, scheme:, startdate: Time.zone.tomorrow, owning_organisation: merging_organisation) }

        before do
          create(:location, scheme: deactivated_scheme)
          create(:scheme_deactivation_period, scheme: deactivated_scheme, deactivation_date: Time.zone.today - 1.month)
          create(:location_deactivation_period, location: deactivated_location, deactivation_date: Time.zone.today - 1.month)
          create(:lettings_log, scheme:, location:, startdate: Time.zone.yesterday)
          create(:lettings_log, startdate: Time.zone.tomorrow, managing_organisation: merging_organisation)
        end

        it "combines organisation schemes and locations" do
          expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
          expect(Rails.logger).to receive(:info).with("\tDanny Rojas (#{merging_organisation.data_protection_officers.first.email})")
          expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
          expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
          expect(Rails.logger).to receive(:info).with(/\t#{scheme.service_name} \(S/)
          merge_organisations_service.call

          new_absorbing_organisation.reload
          expect(new_absorbing_organisation.owned_schemes.count).to eq(1)
          expect(new_absorbing_organisation.owned_schemes.first.service_name).to eq(scheme.service_name)
          expect(new_absorbing_organisation.owned_schemes.first.old_id).to be_nil
          expect(new_absorbing_organisation.owned_schemes.first.old_visible_id).to be_nil
          expect(new_absorbing_organisation.owned_schemes.first.locations.count).to eq(1)
          expect(new_absorbing_organisation.owned_schemes.first.locations.first.postcode).to eq(location.postcode)
          expect(new_absorbing_organisation.owned_schemes.first.locations.first.old_id).to be_nil
          expect(new_absorbing_organisation.owned_schemes.first.locations.first.old_visible_id).to be_nil
          expect(scheme.scheme_deactivation_periods.count).to eq(1)
          expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today)
          expect(scheme.locations.first.location_deactivation_periods.count).to eq(1)
          expect(scheme.locations.first.location_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today)
        end

        it "moves relevant logs and assigns the new scheme" do
          merge_organisations_service.call

          new_absorbing_organisation.reload
          merging_organisation.reload
          expect(new_absorbing_organisation.owned_lettings_logs.count).to eq(2)
          expect(new_absorbing_organisation.managed_lettings_logs.count).to eq(1)
          expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).scheme).to eq(new_absorbing_organisation.owned_schemes.first)
          expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).location).to eq(new_absorbing_organisation.owned_schemes.first.locations.first)
          expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).scheme).to eq(new_absorbing_organisation.owned_schemes.first)
          expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).location).to eq(nil)
        end

        it "rolls back if there's an error" do
          allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
          allow(Organisation).to receive(:find).with(new_absorbing_organisation.id).and_return(new_absorbing_organisation)
          allow(new_absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
          merge_organisations_service.call

          new_absorbing_organisation.reload
          merging_organisation.reload
          expect(new_absorbing_organisation.owned_schemes.count).to eq(0)
          expect(scheme.scheme_deactivation_periods.count).to eq(0)
          expect(scheme.locations.first.location_deactivation_periods.count).to eq(0)
          expect(owned_lettings_log.owning_organisation).to eq(merging_organisation)
          expect(owned_lettings_log_no_location.owning_organisation).to eq(merging_organisation)
        end
      end

      context "and merging sales logs" do
        let!(:sales_log) { create(:sales_log, saledate: Time.zone.tomorrow, owning_organisation: merging_organisation) }

        before do
          create(:sales_log, saledate: Time.zone.yesterday, owning_organisation: merging_organisation)
        end

        it "moves relevant logs" do
          merge_organisations_service.call

          new_absorbing_organisation.reload
          expect(SalesLog.filter_by_owning_organisation(new_absorbing_organisation).count).to eq(1)
          expect(SalesLog.filter_by_owning_organisation(new_absorbing_organisation).first).to eq(sales_log)
        end

        it "rolls back if there's an error" do
          allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
          allow(Organisation).to receive(:find).with(new_absorbing_organisation.id).and_return(new_absorbing_organisation)
          allow(new_absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
          merge_organisations_service.call

          new_absorbing_organisation.reload
          expect(new_absorbing_organisation.sales_logs.count).to eq(0)
          expect(sales_log.owning_organisation).to eq(merging_organisation)
        end
      end

      context "and merge date is provided" do
        subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: new_absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: Time.zone.yesterday) }

        it "sets merge date on merged organisation" do
          merge_organisations_service.call

          merging_organisation.reload
          expect(merging_organisation.merge_date.to_date).to eq(Time.zone.yesterday)
          expect(merging_organisation.absorbing_organisation_id).to eq(new_absorbing_organisation.id)
        end

        context "and merging sales logs" do
          let!(:sales_log) { create(:sales_log, saledate: Time.zone.today, owning_organisation: merging_organisation) }

          before do
            create(:sales_log, saledate: Time.zone.today - 2.days, owning_organisation: merging_organisation)
          end

          it "moves relevant logs" do
            merge_organisations_service.call

            new_absorbing_organisation.reload
            expect(SalesLog.filter_by_owning_organisation(new_absorbing_organisation).count).to eq(1)
            expect(SalesLog.filter_by_owning_organisation(new_absorbing_organisation).first).to eq(sales_log)
          end

          it "rolls back if there's an error" do
            allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
            allow(Organisation).to receive(:find).with(new_absorbing_organisation.id).and_return(new_absorbing_organisation)
            allow(new_absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
            expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
            merge_organisations_service.call

            new_absorbing_organisation.reload
            expect(new_absorbing_organisation.sales_logs.count).to eq(0)
            expect(sales_log.owning_organisation).to eq(merging_organisation)
          end
        end

        context "and merging lettings logs" do
          let(:owning_organisation) { create(:organisation, holds_own_stock: true) }
          let!(:owned_lettings_log) { create(:lettings_log, startdate: Time.zone.today, owning_organisation: merging_organisation, created_by: merging_organisation_user) }
          let!(:managed_lettings_log) { create(:lettings_log, startdate: Time.zone.today) }

          before do
            create(:organisation_relationship) { create(:organisation_relationship, parent_organisation: owning_organisation, child_organisation: merging_organisation) }
            managed_lettings_log.update!(owning_organisation:, managing_organisation: merging_organisation, created_by: merging_organisation_user)
            create(:lettings_log, startdate: Time.zone.today - 2.days, owning_organisation: merging_organisation, created_by: merging_organisation_user)
            create(:lettings_log, startdate: Time.zone.today - 2.days, owning_organisation:, managing_organisation: merging_organisation, created_by: merging_organisation_user)
          end

          it "moves relevant logs" do
            merge_organisations_service.call

            new_absorbing_organisation.reload
            expect(LettingsLog.filter_by_owning_organisation(new_absorbing_organisation).count).to eq(1)
            expect(LettingsLog.filter_by_owning_organisation(new_absorbing_organisation).first).to eq(owned_lettings_log)
            expect(LettingsLog.filter_by_managing_organisation(new_absorbing_organisation).count).to eq(2)
            expect(LettingsLog.filter_by_managing_organisation(new_absorbing_organisation)).to include(managed_lettings_log)
            expect(LettingsLog.filter_by_managing_organisation(new_absorbing_organisation)).to include(owned_lettings_log)
          end

          it "rolls back if there's an error" do
            allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
            allow(Organisation).to receive(:find).with(new_absorbing_organisation.id).and_return(new_absorbing_organisation)
            allow(new_absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
            expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
            merge_organisations_service.call

            new_absorbing_organisation.reload
            expect(new_absorbing_organisation.lettings_logs.count).to eq(0)
            expect(owned_lettings_log.owning_organisation).to eq(merging_organisation)
            expect(managed_lettings_log.managing_organisation).to eq(merging_organisation)
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
            create(:location, scheme: deactivated_scheme)
            create(:scheme_deactivation_period, scheme: deactivated_scheme, deactivation_date: Time.zone.today - 1.month)
            create(:location_deactivation_period, location: deactivated_location, deactivation_date: Time.zone.today - 1.month)
            create(:lettings_log, scheme:, location:, startdate: Time.zone.yesterday)
            create(:lettings_log, startdate: Time.zone.tomorrow, managing_organisation: merging_organisation)
          end

          it "combines organisation schemes and locations" do
            expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
            expect(Rails.logger).to receive(:info).with("\tDanny Rojas (#{merging_organisation.data_protection_officers.first.email})")
            expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
            expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
            expect(Rails.logger).to receive(:info).with(/\t#{scheme.service_name} \(S/)
            merge_organisations_service.call

            new_absorbing_organisation.reload
            expect(new_absorbing_organisation.owned_schemes.count).to eq(1)
            expect(new_absorbing_organisation.owned_schemes.first.service_name).to eq(scheme.service_name)
            expect(new_absorbing_organisation.owned_schemes.first.locations.count).to eq(1)
            expect(new_absorbing_organisation.owned_schemes.first.locations.first.postcode).to eq(location.postcode)
            expect(scheme.scheme_deactivation_periods.count).to eq(1)
            expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.yesterday)
            expect(scheme.locations.first.location_deactivation_periods.count).to eq(1)
            expect(scheme.locations.first.location_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.yesterday)
          end

          it "moves relevant logs and assigns the new scheme" do
            merge_organisations_service.call

            new_absorbing_organisation.reload
            merging_organisation.reload
            expect(new_absorbing_organisation.owned_lettings_logs.count).to eq(2)
            expect(new_absorbing_organisation.managed_lettings_logs.count).to eq(1)
            expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).scheme).to eq(new_absorbing_organisation.owned_schemes.first)
            expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).location).to eq(new_absorbing_organisation.owned_schemes.first.locations.first)
            expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).scheme).to eq(new_absorbing_organisation.owned_schemes.first)
            expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).location).to eq(nil)
          end

          it "rolls back if there's an error" do
            allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
            allow(Organisation).to receive(:find).with(new_absorbing_organisation.id).and_return(new_absorbing_organisation)
            allow(new_absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
            expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
            merge_organisations_service.call

            new_absorbing_organisation.reload
            merging_organisation.reload
            expect(new_absorbing_organisation.owned_schemes.count).to eq(0)
            expect(scheme.scheme_deactivation_periods.count).to eq(0)
            expect(scheme.locations.first.location_deactivation_periods.count).to eq(0)
            expect(owned_lettings_log.owning_organisation).to eq(merging_organisation)
            expect(owned_lettings_log_no_location.owning_organisation).to eq(merging_organisation)
          end
        end

        context "and absorbing_organisation_active_from_merge_date is true" do
          subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: new_absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: Time.zone.yesterday, absorbing_organisation_active_from_merge_date: true) }

          it "sets available from to merge_date for absorbing organisation" do
            merge_organisations_service.call

            new_absorbing_organisation.reload
            expect(new_absorbing_organisation.available_from.to_date).to eq(Time.zone.yesterday)
          end
        end
      end

      context "and absorbing_organisation_active_from_merge_date is true" do
        subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: new_absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], absorbing_organisation_active_from_merge_date: true) }

        it "sets available from to merge_date (today) for absorbing organisation" do
          merge_organisations_service.call

          new_absorbing_organisation.reload
          expect(new_absorbing_organisation.available_from.to_date).to eq(Time.zone.today)
        end
      end
    end

    context "when merging multiple organisations into a new organisation" do
      subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: new_absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: nil) }

      let(:new_absorbing_organisation) { create(:organisation, :without_dpc, holds_own_stock: false) }
      let(:new_absorbing_organisation_user) { create(:user, organisation: new_absorbing_organisation) }

      let(:merging_organisation) { create(:organisation, holds_own_stock: true, name: "fake org") }
      let(:merging_organisation_too) { create(:organisation, holds_own_stock: true, name: "second org") }

      let(:merging_organisation_ids) { [merging_organisation.id, merging_organisation_too.id] }
      let!(:merging_organisation_user) { create(:user, organisation: merging_organisation, name: "fake name", email: "fake@email.com") }

      before do
        create_list(:user, 5, organisation: merging_organisation_too)
      end

      it "moves the users from merging organisations to absorbing organisation" do
        expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
        expect(Rails.logger).to receive(:info).with("\tDanny Rojas (#{merging_organisation.data_protection_officers.first.email})")
        expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
        expect(Rails.logger).to receive(:info).with("Merged users from second org:")
        expect(Rails.logger).to receive(:info).with(/\tDanny Rojas/).exactly(6).times
        expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
        expect(Rails.logger).to receive(:info).with("New schemes from second org:")
        merge_organisations_service.call

        merging_organisation_user.reload
        expect(merging_organisation_user.organisation).to eq(new_absorbing_organisation)
      end

      it "sets merge date and absorbing organisation on merged organisations" do
        merge_organisations_service.call

        merging_organisation.reload
        merging_organisation_too.reload
        expect(merging_organisation.merge_date.to_date).to eq(Time.zone.today)
        expect(merging_organisation.absorbing_organisation_id).to eq(new_absorbing_organisation.id)
        expect(merging_organisation_too.merge_date.to_date).to eq(Time.zone.today)
        expect(merging_organisation_too.absorbing_organisation_id).to eq(new_absorbing_organisation.id)
      end

      it "combines organisation data" do
        merge_organisations_service.call

        new_absorbing_organisation.reload
        expect(new_absorbing_organisation.holds_own_stock).to eq(true)
      end

      it "rolls back if there's an error" do
        allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
        allow(Organisation).to receive(:find).with(new_absorbing_organisation.id).and_return(new_absorbing_organisation)
        allow(new_absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
        expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
        merge_organisations_service.call

        new_absorbing_organisation.reload
        merging_organisation.reload
        expect(new_absorbing_organisation.holds_own_stock).to eq(false)
        expect(merging_organisation.merge_date).to eq(nil)
        expect(merging_organisation.absorbing_organisation_id).to eq(nil)
        expect(merging_organisation_user.organisation).to eq(merging_organisation)
      end

      context "and merging organisation relationships" do
        let(:other_organisation) { create(:organisation) }
        let!(:merging_organisation_relationship) { create(:organisation_relationship, parent_organisation: merging_organisation) }
        let!(:new_absorbing_organisation_relationship) { create(:organisation_relationship, parent_organisation: new_absorbing_organisation) }

        before do
          create(:organisation_relationship, parent_organisation: merging_organisation, child_organisation: new_absorbing_organisation)
          create(:organisation_relationship, parent_organisation: merging_organisation, child_organisation: other_organisation)
          create(:organisation_relationship, parent_organisation: new_absorbing_organisation, child_organisation: other_organisation)
          create(:organisation_relationship, parent_organisation: merging_organisation, child_organisation: merging_organisation_too)
        end

        it "combines organisation relationships" do
          merge_organisations_service.call

          new_absorbing_organisation.reload
          expect(new_absorbing_organisation.child_organisations).to include(other_organisation)
          expect(new_absorbing_organisation.child_organisations).to include(new_absorbing_organisation_relationship.child_organisation)
          expect(new_absorbing_organisation.child_organisations).to include(merging_organisation_relationship.child_organisation)
          expect(new_absorbing_organisation.child_organisations).not_to include(merging_organisation)
          expect(new_absorbing_organisation.parent_organisations).not_to include(merging_organisation)
          expect(new_absorbing_organisation.child_organisations).not_to include(merging_organisation_too)
          expect(new_absorbing_organisation.parent_organisations).not_to include(merging_organisation_too)
          expect(new_absorbing_organisation.parent_organisations.count).to eq(0)
          expect(new_absorbing_organisation.child_organisations.count).to eq(3)
        end

        it "rolls back if there's an error" do
          allow(Organisation).to receive(:find).with([merging_organisation_ids]).and_return(Organisation.find(merging_organisation_ids))
          allow(Organisation).to receive(:find).with(new_absorbing_organisation.id).and_return(new_absorbing_organisation)
          allow(new_absorbing_organisation).to receive(:save!).and_raise(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to receive(:error).with("Organisation merge failed with: Record invalid")
          merge_organisations_service.call

          new_absorbing_organisation.reload
          merging_organisation.reload
          expect(new_absorbing_organisation.child_organisations.count).to eq(2)
          expect(new_absorbing_organisation.parent_organisations.count).to eq(1)
          expect(new_absorbing_organisation.child_organisations).to include(other_organisation)
          expect(new_absorbing_organisation.parent_organisations).to include(merging_organisation)
          expect(new_absorbing_organisation.child_organisations).to include(new_absorbing_organisation_relationship.child_organisation)
        end
      end

      context "and merge date is provided" do
        subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: new_absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: Time.zone.yesterday) }

        it "sets merge date and absorbing organisation on merged organisations" do
          merge_organisations_service.call

          merging_organisation.reload
          merging_organisation_too.reload
          expect(merging_organisation.merge_date.to_date).to eq(Time.zone.yesterday)
          expect(merging_organisation.absorbing_organisation_id).to eq(new_absorbing_organisation.id)
          expect(merging_organisation_too.merge_date.to_date).to eq(Time.zone.yesterday)
          expect(merging_organisation_too.absorbing_organisation_id).to eq(new_absorbing_organisation.id)
        end
      end
    end
  end
end

require "rails_helper"

RSpec.describe Merge::MergeOrganisationsService do
  describe "#call" do
    before do
      Timecop.freeze(Time.zone.local(2024, 3, 1))
      Singleton.__init__(FormHandler)
      mail_double = instance_double("ActionMailer::MessageDelivery", deliver_later: nil)
      allow(MergeCompletionMailer).to receive(:send_merged_organisation_success_mail).and_return(mail_double)
      allow(MergeCompletionMailer).to receive(:send_absorbing_organisation_success_mail).and_return(mail_double)
    end

    after do
      Timecop.return
      Singleton.__init__(FormHandler)
    end

    context "when merging a single organisation into an existing organisation" do
      subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: nil) }

      let(:absorbing_organisation) { create(:organisation, holds_own_stock: false, name: "absorbing org") }
      let(:absorbing_organisation_user) { create(:user, organisation: absorbing_organisation) }

      let(:merging_organisation) { create(:organisation, holds_own_stock: true, name: "fake org") }

      let(:merging_organisation_ids) { [merging_organisation.id] }
      let!(:merging_organisation_user) { create(:user, organisation: merging_organisation, name: "fake name", email: "fake@email.com") }

      it "moves the users from merging organisation to absorbing organisation" do
        expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
        expect(Rails.logger).to receive(:info).with("\t#{merging_organisation.data_protection_officers.first.name} (#{merging_organisation.data_protection_officers.first.email})")
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
        let(:absorbing_organisation) { create(:organisation, holds_own_stock: false, name: "absorbing org") }
        let(:merging_organisation) { create(:organisation, holds_own_stock: true, name: "fake org") }

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
        context "when a scheme and location have no deactivations or startdates" do
          let!(:scheme) { create(:scheme, owning_organisation: merging_organisation, old_id: "scheme_old_id", old_visible_id: "scheme_old_visible_id") }
          let!(:location) { create(:location, scheme:, old_id: "location_old_id", old_visible_id: "location_old_visible_id") }

          it "copies the schemes and locations to absorbing organisation" do
            merge_organisations_service.call

            absorbing_organisation.reload
            expect(absorbing_organisation.owned_schemes.count).to eq(1)

            absorbed_scheme = absorbing_organisation.owned_schemes.first
            expect(absorbed_scheme.locations.count).to eq(1)
            absorbed_location = absorbed_scheme.locations.first

            expect(absorbed_scheme.service_name).to eq(scheme.service_name)
            expect(absorbed_scheme.old_id).to be_nil
            expect(absorbed_scheme.old_visible_id).to be_nil
            expect(absorbed_scheme.startdate).to eq(Time.zone.today)

            expect(absorbed_location.postcode).to eq(location.postcode)
            expect(absorbed_location.old_id).to be_nil
            expect(absorbed_location.old_visible_id).to be_nil
            expect(absorbed_location.startdate).to eq(Time.zone.today)
          end

          it "deactivates schemes and locations on the merged organisation" do
            merge_organisations_service.call
            expect(scheme.owning_organisation).to eq(merging_organisation)
            expect(location.scheme).to eq(scheme)
            expect(scheme.scheme_deactivation_periods.count).to eq(1)
            expect(scheme.scheme_deactivation_periods.first.deactivation_date).to eq(Time.zone.today)
            expect(location.location_deactivation_periods.count).to eq(1)
            expect(location.location_deactivation_periods.first.deactivation_date).to eq(Time.zone.today)
          end
        end

        context "when a scheme and location have a startdate but no deactivations" do
          context "and the startdate is before the merge date" do
            let!(:scheme) { create(:scheme, owning_organisation: merging_organisation, old_id: "scheme_old_id", old_visible_id: "scheme_old_visible_id", startdate: Time.zone.today - 1.month) }
            let!(:location) { create(:location, scheme:, old_id: "location_old_id", old_visible_id: "location_old_visible_id", startdate: Time.zone.today - 1.month) }

            it "sets the startdate to merge date for schemes and locations moved to absorbed organisation" do
              merge_organisations_service.call

              absorbing_organisation.reload
              expect(absorbing_organisation.owned_schemes.count).to eq(1)

              absorbed_scheme = absorbing_organisation.owned_schemes.first
              expect(absorbed_scheme.locations.count).to eq(1)
              absorbed_location = absorbed_scheme.locations.first

              expect(absorbed_scheme.startdate).to eq(Time.zone.today)
              expect(absorbed_location.startdate).to eq(Time.zone.today)
            end

            it "deactivates schemes and locations on the merged organisation" do
              merge_organisations_service.call

              absorbing_organisation.reload
              expect(scheme.owning_organisation).to eq(merging_organisation)
              expect(location.scheme).to eq(scheme)
              expect(scheme.scheme_deactivation_periods.count).to eq(1)
              expect(scheme.scheme_deactivation_periods.first.deactivation_date).to eq(Time.zone.today)
              expect(location.location_deactivation_periods.count).to eq(1)
              expect(location.location_deactivation_periods.first.deactivation_date).to eq(Time.zone.today)
            end
          end

          context "and the startdate is after the merge date" do
            let!(:scheme) { create(:scheme, owning_organisation: merging_organisation, old_id: "scheme_old_id", old_visible_id: "scheme_old_visible_id", startdate: Time.zone.today + 1.month) }
            let!(:location) { create(:location, scheme:, old_id: "location_old_id", old_visible_id: "location_old_visible_id", startdate: Time.zone.today + 1.month) }

            it "keeps the existing startdate for schemes and locations moved to absorbed organisation" do
              merge_organisations_service.call

              absorbing_organisation.reload
              expect(absorbing_organisation.owned_schemes.count).to eq(1)

              absorbed_scheme = absorbing_organisation.owned_schemes.first
              expect(absorbed_scheme.locations.count).to eq(1)
              absorbed_location = absorbed_scheme.locations.first

              expected_date = Time.zone.today + 1.month
              expect(absorbed_scheme.startdate).to eq(expected_date.in_time_zone)
              expect(absorbed_location.startdate).to eq(expected_date.in_time_zone)
            end

            it "deactivates schemes and locations on the merged organisation on the startdate" do
              merge_organisations_service.call

              expected_date = Time.zone.today + 1.month
              expect(scheme.owning_organisation).to eq(merging_organisation)
              expect(location.scheme).to eq(scheme)
              expect(scheme.scheme_deactivation_periods.count).to eq(1)
              expect(scheme.scheme_deactivation_periods.first.deactivation_date).to eq(expected_date.in_time_zone)
              expect(location.location_deactivation_periods.count).to eq(1)
              expect(location.location_deactivation_periods.first.deactivation_date).to eq(expected_date.in_time_zone)
            end
          end
        end

        context "when a scheme and location have a deactivations but no startdates" do
          context "and deactivation is before the merge date" do
            let!(:scheme) { create(:scheme, owning_organisation: merging_organisation, old_id: "scheme_old_id", old_visible_id: "scheme_old_visible_id", startdate: nil) }
            let!(:location) { create(:location, scheme:, old_id: "location_old_id", old_visible_id: "location_old_visible_id", startdate: nil) }

            before do
              create(:scheme_deactivation_period, scheme:, deactivation_date: Time.zone.today - 2.months, reactivation_date: Time.zone.today - 1.month)
              create(:location_deactivation_period, location:, deactivation_date: Time.zone.today - 2.months, reactivation_date: Time.zone.today - 1.month)
              merge_organisations_service.call

              absorbing_organisation.reload
              scheme.scheme_deactivation_periods.reload
              location.location_deactivation_periods.reload
            end

            it "does not move the deactivation" do
              expect(absorbing_organisation.owned_schemes.count).to eq(1)

              absorbed_scheme = absorbing_organisation.owned_schemes.first
              expect(absorbed_scheme.locations.count).to eq(1)
              absorbed_location = absorbed_scheme.locations.first

              expect(absorbed_scheme.startdate).to eq(Time.zone.today)
              expect(absorbed_scheme.scheme_deactivation_periods.count).to eq(0)

              expect(absorbed_location.startdate).to eq(Time.zone.today)
              expect(absorbed_location.location_deactivation_periods.count).to eq(0)
            end

            it "deactivates schemes and locations on the merged organisation" do
              expect(scheme.owning_organisation).to eq(merging_organisation)
              expect(location.scheme).to eq(scheme)
              expect(scheme.scheme_deactivation_periods.count).to eq(2)
              expect(scheme.scheme_deactivation_periods.last.deactivation_date).to eq(Time.zone.today)
              expect(location.location_deactivation_periods.count).to eq(2)
              expect(location.location_deactivation_periods.last.deactivation_date).to eq(Time.zone.today)
            end
          end

          context "and deactivation is after the merge date" do
            let!(:scheme) { create(:scheme, owning_organisation: merging_organisation, old_id: "scheme_old_id", old_visible_id: "scheme_old_visible_id", startdate: nil) }
            let!(:location) { create(:location, scheme:, old_id: "location_old_id", old_visible_id: "location_old_visible_id", startdate: nil) }

            before do
              create(:scheme_deactivation_period, scheme:, deactivation_date: Time.zone.today + 1.month, reactivation_date: Time.zone.today + 2.months)
              create(:location_deactivation_period, location:, deactivation_date: Time.zone.today + 3.months)
              merge_organisations_service.call
              absorbing_organisation.reload
              scheme.scheme_deactivation_periods.reload
              location.location_deactivation_periods.reload
            end

            it "moves the deactivations to absorbing organisation and removes them from merging organisations" do
              expect(absorbing_organisation.owned_schemes.count).to eq(1)

              absorbed_scheme = absorbing_organisation.owned_schemes.first
              expect(absorbed_scheme.locations.count).to eq(1)
              absorbed_location = absorbed_scheme.locations.first

              expect(absorbed_scheme.startdate).to eq(Time.zone.today)
              expect(absorbed_scheme.scheme_deactivation_periods.count).to eq(1)

              expect(absorbed_location.startdate).to eq(Time.zone.today)
              expect(absorbed_location.location_deactivation_periods.count).to eq(1)
            end

            it "deactivates schemes and locations on the merged organisation" do
              expect(scheme.owning_organisation).to eq(merging_organisation)
              expect(location.scheme).to eq(scheme)
              expect(scheme.scheme_deactivation_periods.count).to eq(1)
              expect(scheme.scheme_deactivation_periods.last.deactivation_date).to eq(Time.zone.today)
              expect(location.location_deactivation_periods.count).to eq(1)
              expect(location.location_deactivation_periods.last.deactivation_date).to eq(Time.zone.today)
            end
          end

          context "and deactivation is after the merge date and before an open collection window" do
            subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: Time.zone.today - 6.years) }

            let!(:scheme) { create(:scheme, owning_organisation: merging_organisation, old_id: "scheme_old_id", old_visible_id: "scheme_old_visible_id", startdate: nil) }
            let!(:location) { create(:location, scheme:, old_id: "location_old_id", old_visible_id: "location_old_visible_id", startdate: nil) }

            before do
              scheme_deactivation_period = build(:scheme_deactivation_period, scheme:, deactivation_date: Time.zone.today - 3.years, reactivation_date: Time.zone.today - 3.months)
              scheme_deactivation_period.save!(validate: false)
              location_deactivation_period = build(:location_deactivation_period, location:, deactivation_date: Time.zone.today - 4.years)
              location_deactivation_period.save!(validate: false)
              merge_organisations_service.call
              absorbing_organisation.reload
              scheme.scheme_deactivation_periods.reload
              location.location_deactivation_periods.reload
            end

            it "moves the deactivations to absorbing organisation and removes them from merging organisations" do
              expected_startdate = (Time.zone.today - 6.years).in_time_zone

              expect(absorbing_organisation.owned_schemes.count).to eq(1)

              absorbed_scheme = absorbing_organisation.owned_schemes.first
              expect(absorbed_scheme.locations.count).to eq(1)
              absorbed_location = absorbed_scheme.locations.first

              expect(absorbed_scheme.startdate).to eq(expected_startdate)
              expect(absorbed_scheme.scheme_deactivation_periods.count).to eq(1)

              expect(absorbed_location.startdate).to eq(expected_startdate)
              expect(absorbed_location.location_deactivation_periods.count).to eq(1)
            end

            it "deactivates schemes and locations on the merged organisation" do
              expected_deactivation_date = (Time.zone.today - 6.years).in_time_zone

              expect(scheme.owning_organisation).to eq(merging_organisation)
              expect(location.scheme).to eq(scheme)
              expect(scheme.scheme_deactivation_periods.count).to eq(1)
              expect(scheme.scheme_deactivation_periods.last.deactivation_date).to eq(expected_deactivation_date)
              expect(location.location_deactivation_periods.count).to eq(1)
              expect(location.location_deactivation_periods.last.deactivation_date).to eq(expected_deactivation_date)
            end
          end

          context "and deactivation is during the merge date and it has a reactivation date" do
            let!(:scheme) { create(:scheme, owning_organisation: merging_organisation, old_id: "scheme_old_id", old_visible_id: "scheme_old_visible_id", startdate: nil) }
            let!(:location) { create(:location, scheme:, old_id: "location_old_id", old_visible_id: "location_old_visible_id", startdate: nil) }

            before do
              create(:scheme_deactivation_period, scheme:, deactivation_date: Time.zone.today - 1.month, reactivation_date: Time.zone.today + 1.month)
              create(:location_deactivation_period, location:, deactivation_date: Time.zone.today - 3.months, reactivation_date: Time.zone.today + 1.month)
              merge_organisations_service.call

              absorbing_organisation.reload
              scheme.scheme_deactivation_periods.reload
              location.location_deactivation_periods.reload
            end

            it "moves the deactivation to absorbing organisation with merge_date as deactivation_date and removes reactivation date on merged organisation scheme and location" do
              expect(absorbing_organisation.owned_schemes.count).to eq(1)

              absorbed_scheme = absorbing_organisation.owned_schemes.first
              expect(absorbed_scheme.locations.count).to eq(1)
              absorbed_location = absorbed_scheme.locations.first

              expected_reactivation_date = Time.zone.today + 1.month
              expect(absorbed_scheme.startdate).to eq(Time.zone.today)
              expect(absorbed_scheme.scheme_deactivation_periods.count).to eq(1)
              expect(absorbed_scheme.scheme_deactivation_periods.first.deactivation_date).to eq(Time.zone.today)
              expect(absorbed_scheme.scheme_deactivation_periods.first.reactivation_date).to eq(expected_reactivation_date.in_time_zone)

              expect(absorbed_location.startdate).to eq(Time.zone.today)
              expect(absorbed_location.location_deactivation_periods.count).to eq(1)
              expect(absorbed_location.location_deactivation_periods.first.deactivation_date).to eq(Time.zone.today)
              expect(absorbed_location.location_deactivation_periods.first.reactivation_date).to eq(expected_reactivation_date.in_time_zone)
            end

            it "deactivates schemes and locations on the merged organisation" do
              expect(scheme.owning_organisation).to eq(merging_organisation)
              expect(location.scheme).to eq(scheme)
              expect(scheme.scheme_deactivation_periods.count).to eq(1)
              expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today - 1.month)
              expect(scheme.scheme_deactivation_periods.first.reactivation_date).to be_nil
              expect(location.location_deactivation_periods.count).to eq(1)
              expect(location.location_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today - 3.months)
              expect(location.location_deactivation_periods.first.reactivation_date).to be_nil
            end
          end

          context "and deactivation is during the merge date and it doesn't have a reactivation date" do
            let!(:scheme) { create(:scheme, owning_organisation: merging_organisation, old_id: "scheme_old_id", old_visible_id: "scheme_old_visible_id", startdate: nil) }
            let!(:location) { create(:location, scheme:, old_id: "location_old_id", old_visible_id: "location_old_visible_id", startdate: nil) }

            before do
              create(:scheme_deactivation_period, scheme:, deactivation_date: Time.zone.today - 1.month)
              create(:location_deactivation_period, location:, deactivation_date: Time.zone.today - 3.months)
            end

            it "moves the deactivation to absorbing organisation with merge_date as deactivation_date and does not deactivate merged org schemes and locations again" do
              merge_organisations_service.call

              absorbing_organisation.reload
              scheme.scheme_deactivation_periods.reload
              location.location_deactivation_periods.reload
              expect(absorbing_organisation.owned_schemes.count).to eq(1)

              absorbed_scheme = absorbing_organisation.owned_schemes.first
              expect(absorbed_scheme.locations.count).to eq(1)
              absorbed_location = absorbed_scheme.locations.first

              expect(absorbed_scheme.startdate).to eq(Time.zone.today)
              expect(absorbed_scheme.scheme_deactivation_periods.count).to eq(1)
              expect(absorbed_scheme.scheme_deactivation_periods.first.deactivation_date).to eq(Time.zone.today)
              expect(absorbed_scheme.scheme_deactivation_periods.first.reactivation_date).to be_nil

              expect(absorbed_location.startdate).to eq(Time.zone.today)
              expect(absorbed_location.location_deactivation_periods.count).to eq(1)
              expect(absorbed_location.location_deactivation_periods.first.deactivation_date).to eq(Time.zone.today)
              expect(absorbed_location.location_deactivation_periods.first.reactivation_date).to be_nil

              expect(scheme.owning_organisation).to eq(merging_organisation)
              expect(location.scheme).to eq(scheme)
              expect(scheme.scheme_deactivation_periods.count).to eq(1)
              expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today - 1.month)
              expect(scheme.scheme_deactivation_periods.first.reactivation_date).to be_nil
              expect(location.location_deactivation_periods.count).to eq(1)
              expect(location.location_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today - 3.months)
              expect(location.location_deactivation_periods.first.reactivation_date).to be_nil
            end
          end
        end

        context "with multiple schemes and locations" do
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

          it "logs the merged schemes and locations" do
            expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
            expect(Rails.logger).to receive(:info).with("\t#{merging_organisation.data_protection_officers.first.name} (#{merging_organisation.data_protection_officers.first.email})")
            expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
            expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
            expect(Rails.logger).to receive(:info).with(/\t#{scheme.service_name} \(S/)
            expect(Rails.logger).to receive(:info).with(/\t#{deactivated_scheme.service_name} \(S/)
            merge_organisations_service.call
          end

          context "when combining organisation schemes and locations" do
            before do
              merge_organisations_service.call
              absorbing_organisation.reload
              deactivated_scheme.reload
              deactivated_location.reload
              merging_organisation.reload
            end

            it "moves active schemes and locations to absorbing organisation" do
              expect(absorbing_organisation.owned_schemes.count).to eq(2)

              absorbed_active_scheme = absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name)
              absorbed_active_location = absorbed_active_scheme.locations.find_by(postcode: location.postcode)
              expect(absorbed_active_scheme.service_name).to eq(scheme.service_name)
              expect(absorbed_active_scheme.old_id).to be_nil
              expect(absorbed_active_scheme.old_visible_id).to be_nil
              expect(absorbed_active_scheme.locations.count).to eq(2)
              expect(absorbed_active_location.postcode).to eq(location.postcode)
              expect(absorbed_active_location.old_id).to be_nil
              expect(absorbed_active_location.old_visible_id).to be_nil
            end

            it "deactivates active schemes and locations on merging organisation" do
              expect(scheme.scheme_deactivation_periods.count).to eq(1)
              expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today)
              expect(scheme.locations.find_by(postcode: location.postcode).location_deactivation_periods.count).to eq(1)
              expect(scheme.locations.find_by(postcode: location.postcode).location_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today)
            end

            it "does not deactivate inactive locations on merging organisation again" do
              expect(scheme.locations.find_by(postcode: deactivated_location.postcode).location_deactivation_periods.count).to eq(1)
            end

            it "moves inactive schemes and their locations to absorbing organisation" do
              absorbed_inactive_scheme = absorbing_organisation.owned_schemes.find_by(service_name: deactivated_scheme.service_name)
              expect(absorbed_inactive_scheme.scheme_deactivation_periods.count).to eq(1)
              expect(absorbed_inactive_scheme.scheme_deactivation_periods.first.deactivation_date).to eq(merging_organisation.merge_date)
              expect(absorbed_inactive_scheme.locations.count).to eq(1)
              expect(absorbed_inactive_scheme.locations.first.location_deactivation_periods.count).to eq(0)
              expect(deactivated_scheme.scheme_deactivation_periods.count).to eq(1)
            end

            it "moves inactive locations of active schemes to absorbing organisation" do
              absorbed_active_scheme = absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name)
              absorbed_inactive_location = absorbed_active_scheme.locations.find_by(postcode: deactivated_location.postcode)
              expect(absorbed_active_scheme.scheme_deactivation_periods.count).to eq(0)
              expect(absorbed_inactive_location.location_deactivation_periods.count).to eq(1)
              expect(absorbed_inactive_location.location_deactivation_periods.first.deactivation_date).to eq(merging_organisation.merge_date)
            end
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
      end

      context "and merging sales logs" do
        let!(:sales_log) { create(:sales_log, :completed, saledate: Time.zone.tomorrow, owning_organisation: merging_organisation) }

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

        context "with merge date in closed collection year" do
          subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: Time.zone.local(2021, 3, 3)) }

          it "does not validate saledate for closed collection years" do
            sales_log.saledate = Time.zone.local(2022, 5, 1)
            sales_log.save!(validate: false)
            merge_organisations_service.call

            absorbing_organisation.reload
            sales_log.reload
            expect(sales_log.owning_organisation).to eq(absorbing_organisation)
          end
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
          let(:owning_organisation) { create(:organisation, holds_own_stock: true) }
          let!(:sales_log) { create(:sales_log, saledate: Time.zone.today, owning_organisation: merging_organisation, managing_organisation: merging_organisation, purchid: "owned") }
          let!(:managed_sales_log) { create(:sales_log, saledate: Time.zone.today, purchid: "managed") }

          before do
            create(:sales_log, saledate: Time.zone.today - 2.days, owning_organisation: merging_organisation)
            create(:organisation_relationship) { create(:organisation_relationship, parent_organisation: owning_organisation, child_organisation: merging_organisation) }
            managed_sales_log.update!(owning_organisation:, managing_organisation: merging_organisation, assigned_to: merging_organisation_user)
            create(:sales_log, saledate: Time.zone.today - 2.days, owning_organisation: merging_organisation, assigned_to: merging_organisation_user, purchid: "ranom 1")
            create(:sales_log, saledate: Time.zone.today - 2.days, owning_organisation:, managing_organisation: merging_organisation, assigned_to: merging_organisation_user, purchid: "ranom 2")
          end

          it "moves relevant logs" do
            merge_organisations_service.call

            absorbing_organisation.reload
            expect(SalesLog.filter_by_owning_organisation(absorbing_organisation).count).to eq(1)
            expect(SalesLog.filter_by_owning_organisation(absorbing_organisation).first).to eq(sales_log)
            expect(SalesLog.filter_by_managing_organisation(absorbing_organisation).count).to eq(2)
            expect(SalesLog.filter_by_managing_organisation(absorbing_organisation)).to include(managed_sales_log)
            expect(SalesLog.filter_by_managing_organisation(absorbing_organisation)).to include(sales_log)
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
          let!(:owned_lettings_log) { create(:lettings_log, :completed, startdate: Time.zone.today, owning_organisation: merging_organisation, managing_organisation: merging_organisation, assigned_to: merging_organisation_user) }
          let!(:managed_lettings_log) { create(:lettings_log, startdate: Time.zone.today) }

          before do
            create(:organisation_relationship) { create(:organisation_relationship, parent_organisation: owning_organisation, child_organisation: merging_organisation) }
            managed_lettings_log.update!(owning_organisation:, managing_organisation: merging_organisation, assigned_to: merging_organisation_user)
            create(:lettings_log, startdate: Time.zone.today - 2.days, owning_organisation: merging_organisation, assigned_to: merging_organisation_user)
            create(:lettings_log, startdate: Time.zone.today - 2.days, owning_organisation:, managing_organisation: merging_organisation, assigned_to: merging_organisation_user)
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

          it "does not clear any answers if the owning and managing organisation are the same" do
            expect(owned_lettings_log.status).to eq("completed")
            merge_organisations_service.call

            absorbing_organisation.reload
            owned_lettings_log.reload
            expect(owned_lettings_log.status).to eq("completed")
            expect(owned_lettings_log.owning_organisation).to eq(absorbing_organisation)
            expect(owned_lettings_log.managing_organisation).to eq(absorbing_organisation)
          end

          context "with merge date in closed collection year" do
            subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: Time.zone.local(2021, 3, 3)) }

            it "does not validate startdate for closed collection years" do
              owned_lettings_log.startdate = Time.zone.local(2022, 4, 1)
              owned_lettings_log.save!(validate: false)
              merge_organisations_service.call

              absorbing_organisation.reload
              owned_lettings_log.reload
              expect(owned_lettings_log.owning_organisation).to eq(absorbing_organisation)
              expect(owned_lettings_log.managing_organisation).to eq(absorbing_organisation)
            end
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

          context "with multiple locations" do
            let!(:location_without_startdate) { create(:location, scheme:, startdate: nil) }
            let!(:location_with_past_startdate) { create(:location, scheme:, startdate: Time.zone.today - 2.months) }
            let!(:location_with_future_startdate) { create(:location, scheme:, startdate: Time.zone.today + 2.months) }

            it "logs the merged schemes" do
              expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
              expect(Rails.logger).to receive(:info).with("\t#{merging_organisation.data_protection_officers.first.name} (#{merging_organisation.data_protection_officers.first.email})")
              expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
              expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
              expect(Rails.logger).to receive(:info).with(/\t#{scheme.service_name} \(S/)
              expect(Rails.logger).to receive(:info).with(/\t#{deactivated_scheme.service_name} \(S/)

              merge_organisations_service.call
            end

            context "when combining organisation schemes and locations" do
              before do
                merge_organisations_service.call

                absorbing_organisation.reload
                deactivated_scheme.reload
                deactivated_location.reload
                merging_organisation.reload
              end

              it "moves active schemes and locations to absorbing organisation" do
                expect(absorbing_organisation.owned_schemes.count).to eq(2)

                expect(absorbing_organisation.owned_schemes.first.locations.map(&:postcode)).to match_array([location, deactivated_location, location_without_startdate, location_with_past_startdate, location_with_future_startdate].map(&:postcode))
                expect(absorbing_organisation.owned_schemes.first.locations.find_by(postcode: location_without_startdate.postcode).startdate).to eq(Time.zone.yesterday)
                expect(absorbing_organisation.owned_schemes.first.locations.find_by(postcode: location_with_past_startdate.postcode).startdate).to eq(Time.zone.yesterday)
                expect(absorbing_organisation.owned_schemes.first.locations.find_by(postcode: location_with_future_startdate.postcode).startdate.to_date).to eq(Time.zone.today + 2.months)
                absorbed_active_scheme = absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name)
                absorbed_active_location = absorbed_active_scheme.locations.find_by(postcode: location.postcode)
                expect(absorbed_active_scheme.service_name).to eq(scheme.service_name)
                expect(absorbed_active_scheme.old_id).to be_nil
                expect(absorbed_active_scheme.old_visible_id).to be_nil
                expect(absorbed_active_scheme.locations.count).to eq(5)
                expect(absorbed_active_location.postcode).to eq(location.postcode)
                expect(absorbed_active_location.old_id).to be_nil
                expect(absorbed_active_location.old_visible_id).to be_nil
              end

              it "deactivates active schemes and locations on merging organisation" do
                expect(scheme.scheme_deactivation_periods.count).to eq(1)
                expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.yesterday)
                expect(scheme.locations.find_by(postcode: location.postcode).location_deactivation_periods.count).to eq(1)
                expect(scheme.locations.find_by(postcode: location.postcode).location_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.yesterday)
              end

              it "does not deactivate inactive locations on merging organisation again" do
                expect(scheme.locations.find_by(postcode: deactivated_location.postcode).location_deactivation_periods.count).to eq(1)
              end

              it "moves inactive schemes and their locations to absorbing organisation" do
                absorbed_inactive_scheme = absorbing_organisation.owned_schemes.find_by(service_name: deactivated_scheme.service_name)
                expect(absorbed_inactive_scheme.scheme_deactivation_periods.count).to eq(1)
                expect(absorbed_inactive_scheme.scheme_deactivation_periods.first.deactivation_date).to eq(merging_organisation.merge_date)
                expect(absorbed_inactive_scheme.locations.count).to eq(1)
                expect(absorbed_inactive_scheme.locations.first.location_deactivation_periods.count).to eq(0)
                expect(deactivated_scheme.scheme_deactivation_periods.count).to eq(1)
              end

              it "moves inactive locations of active schemes to absorbing organisation" do
                absorbed_active_scheme = absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name)
                absorbed_inactive_location = absorbed_active_scheme.locations.find_by(postcode: deactivated_location.postcode)
                expect(absorbed_active_scheme.scheme_deactivation_periods.count).to eq(0)
                expect(absorbed_inactive_location.location_deactivation_periods.count).to eq(1)
                expect(absorbed_inactive_location.location_deactivation_periods.first.deactivation_date).to eq(merging_organisation.merge_date)
              end
            end
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

      it "sends a merge completion E-mail to the merged organisation users" do
        expect(MergeCompletionMailer).to receive(:send_merged_organisation_success_mail).with(merging_organisation_user.email, "fake org", "absorbing org", Time.zone.today).once
        expect(MergeCompletionMailer).to receive(:send_merged_organisation_success_mail).with(merging_organisation.data_protection_officers.first.email, "fake org", "absorbing org", Time.zone.today).once

        expect(MergeCompletionMailer).not_to receive(:send_merged_organisation_success_mail).with(absorbing_organisation.data_protection_officers.first.email, "fake org", "absorbing org", Time.zone.today)
        expect(MergeCompletionMailer).not_to receive(:send_merged_organisation_success_mail).with(absorbing_organisation_user.email, "fake org", "absorbing org", Time.zone.today)

        merge_organisations_service.call
      end

      it "does not send a merge completion E-mail to deactivated merged organisation users" do
        merging_organisation_user.update!(active: false)

        expect(MergeCompletionMailer).to receive(:send_merged_organisation_success_mail).with(merging_organisation.data_protection_officers.first.email, "fake org", "absorbing org", Time.zone.today).once

        expect(MergeCompletionMailer).not_to receive(:send_merged_organisation_success_mail).with(merging_organisation_user.email, "fake org", "absorbing org", Time.zone.today)
        expect(MergeCompletionMailer).not_to receive(:send_merged_organisation_success_mail).with(absorbing_organisation.data_protection_officers.first.email, "fake org", "absorbing org", Time.zone.today)
        expect(MergeCompletionMailer).not_to receive(:send_merged_organisation_success_mail).with(absorbing_organisation_user.email, "fake org", "absorbing org", Time.zone.today)

        merge_organisations_service.call
      end

      it "sends a merge completion E-mail to the original absorbing organisation users" do
        expect(MergeCompletionMailer).to receive(:send_absorbing_organisation_success_mail).with(absorbing_organisation.data_protection_officers.first.email, ["fake org"], "absorbing org", Time.zone.today).once
        expect(MergeCompletionMailer).to receive(:send_absorbing_organisation_success_mail).with(absorbing_organisation_user.email, ["fake org"], "absorbing org", Time.zone.today).once

        expect(MergeCompletionMailer).not_to receive(:send_absorbing_organisation_success_mail).with(merging_organisation_user.email, ["fake org"], "absorbing org", Time.zone.today)
        expect(MergeCompletionMailer).not_to receive(:send_absorbing_organisation_success_mail).with(merging_organisation.data_protection_officers.first.email, ["fake org"], "absorbing org", Time.zone.today)

        merge_organisations_service.call
      end

      it "does not send a merge completion E-mail to deactivated original absorbing organisation users" do
        absorbing_organisation_user.update!(active: false)

        expect(MergeCompletionMailer).to receive(:send_absorbing_organisation_success_mail).with(absorbing_organisation.data_protection_officers.first.email, ["fake org"], "absorbing org", Time.zone.today).once

        expect(MergeCompletionMailer).not_to receive(:send_absorbing_organisation_success_mail).with(absorbing_organisation_user.email, ["fake org"], "absorbing org", Time.zone.today)
        expect(MergeCompletionMailer).not_to receive(:send_absorbing_organisation_success_mail).with(merging_organisation_user.email, ["fake org"], "absorbing org", Time.zone.today)
        expect(MergeCompletionMailer).not_to receive(:send_absorbing_organisation_success_mail).with(merging_organisation.data_protection_officers.first.email, ["fake org"], "absorbing org", Time.zone.today)

        merge_organisations_service.call
      end
    end

    context "when merging a multiple organisations into an existing organisation" do
      subject(:merge_organisations_service) { described_class.new(absorbing_organisation_id: absorbing_organisation.id, merging_organisation_ids: [merging_organisation_ids], merge_date: nil) }

      let(:absorbing_organisation) { create(:organisation, holds_own_stock: false, name: "absorbing org") }
      let(:absorbing_organisation_user) { create(:user, organisation: absorbing_organisation) }

      let(:merging_organisation) { create(:organisation, holds_own_stock: true, name: "fake org") }
      let(:merging_organisation_too) { create(:organisation, holds_own_stock: true, name: "second org") }

      let(:merging_organisation_ids) { [merging_organisation.id, merging_organisation_too.id] }
      let!(:merging_organisation_user) { create(:user, organisation: merging_organisation, name: "fake name", email: "fake@email.com") }

      before do
        create_list(:user, 5, organisation: merging_organisation_too, name: "Danny Rojas")
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

      context "and merging users" do
        it "moves the users from merging organisations to absorbing organisation" do
          expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
          expect(Rails.logger).to receive(:info).with("\t#{merging_organisation.data_protection_officers.first.name} (#{merging_organisation.data_protection_officers.first.email})")
          expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
          expect(Rails.logger).to receive(:info).with("Merged users from second org:")
          expect(Rails.logger).to receive(:info).with(/\tDanny Rojas/).exactly(5).times
          expect(Rails.logger).to receive(:info).with(/\t#{merging_organisation_too.data_protection_officers.first.name}/)
          expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
          expect(Rails.logger).to receive(:info).with("New schemes from second org:")
          merge_organisations_service.call

          merging_organisation_user.reload
          expect(merging_organisation_user.organisation).to eq(absorbing_organisation)
        end

        it "replaces dpo users with fake users if they have signed the data sharing agreement" do
          merging_organisation_user.update!(is_dpo: true)
          merging_organisation.data_protection_confirmation.update!(data_protection_officer: merging_organisation_user)

          merge_organisations_service.call

          merging_organisation_user.reload
          merging_organisation.reload
          expect(merging_organisation_user.organisation).to eq(absorbing_organisation)
          expect(merging_organisation.users.count).to eq(1)
          expect(merging_organisation.users.first.name).to eq(merging_organisation_user.name)
          expect(merging_organisation.users.first.email).not_to eq(merging_organisation_user.email)
          expect(merging_organisation.data_protection_confirmation.data_protection_officer).to eq(merging_organisation.users.first)
        end

        it "does not move dpo users who have signed data sharing agreement if they have a fake email address" do
          dpo = User.new(
            name: merging_organisation.data_protection_confirmation.data_protection_officer.name,
            organisation: merging_organisation,
            is_dpo: true,
            encrypted_password: SecureRandom.hex(10),
            email: SecureRandom.uuid,
            confirmed_at: Time.zone.now,
            active: false,
          )
          dpo.save!(validate: false)
          merging_organisation.data_protection_confirmation.update!(data_protection_officer: dpo)

          merge_organisations_service.call

          dpo.reload
          merging_organisation.reload
          expect(dpo.organisation).to eq(merging_organisation)
          expect(merging_organisation.users.count).to eq(1)
          expect(merging_organisation.users.first).to eq(dpo)
          expect(merging_organisation.data_protection_confirmation.data_protection_officer).to eq(dpo)
        end

        it "sends a merge completion E-mail to the merged organisation users" do
          expect(MergeCompletionMailer).to receive(:send_merged_organisation_success_mail).with(merging_organisation_user.email, "fake org", "absorbing org", Time.zone.today).once
          expect(MergeCompletionMailer).to receive(:send_merged_organisation_success_mail).with(merging_organisation.data_protection_officers.first.email, "fake org", "absorbing org", Time.zone.today).once

          expect(MergeCompletionMailer).not_to receive(:send_merged_organisation_success_mail).with(absorbing_organisation.data_protection_officers.first.email, "fake org", "absorbing org", Time.zone.today)
          expect(MergeCompletionMailer).not_to receive(:send_merged_organisation_success_mail).with(absorbing_organisation_user.email, "fake org", "absorbing org", Time.zone.today)

          merging_organisation_too.users.each do |user|
            expect(MergeCompletionMailer).to receive(:send_merged_organisation_success_mail).with(user.email, "second org", "absorbing org", Time.zone.today).once
          end

          merge_organisations_service.call
        end

        it "sends a merge completion E-mail to the original absorbing organisation users" do
          expect(MergeCompletionMailer).to receive(:send_absorbing_organisation_success_mail).with(absorbing_organisation.data_protection_officers.first.email, ["fake org", "second org"], "absorbing org", Time.zone.today).once
          expect(MergeCompletionMailer).to receive(:send_absorbing_organisation_success_mail).with(absorbing_organisation_user.email, ["fake org", "second org"], "absorbing org", Time.zone.today).once

          expect(MergeCompletionMailer).not_to receive(:send_absorbing_organisation_success_mail).with(merging_organisation_user.email, ["fake org", "second org"], "absorbing org", Time.zone.today)
          expect(MergeCompletionMailer).not_to receive(:send_absorbing_organisation_success_mail).with(merging_organisation.data_protection_officers.first.email, ["fake org", "second org"], "absorbing org", Time.zone.today)

          merging_organisation_too.users.each do |user|
            expect(MergeCompletionMailer).not_to receive(:send_absorbing_organisation_success_mail).with(user.email, ["fake org", "second org"], "absorbing org", Time.zone.today)
          end

          merge_organisations_service.call
        end
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
        expect(Rails.logger).to receive(:info).with("\t#{merging_organisation.data_protection_officers.first.name} (#{merging_organisation.data_protection_officers.first.email})")
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
        let(:new_absorbing_organisation) { create(:organisation, :without_dpc, holds_own_stock: false) }
        let(:merging_organisation) { create(:organisation, holds_own_stock: true, name: "fake org") }

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

        it "logs the merged schemes" do
          expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
          expect(Rails.logger).to receive(:info).with("\t#{merging_organisation.data_protection_officers.first.name} (#{merging_organisation.data_protection_officers.first.email})")
          expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
          expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
          expect(Rails.logger).to receive(:info).with(/\t#{scheme.service_name} \(S/)
          expect(Rails.logger).to receive(:info).with(/\t#{deactivated_scheme.service_name} \(S/)
          merge_organisations_service.call
        end

        context "when combining organisation schemes and locations" do
          before do
            merge_organisations_service.call
            new_absorbing_organisation.reload
            deactivated_scheme.reload
            deactivated_location.reload
            merging_organisation.reload
          end

          it "moves active schemes and locations to absorbing organisation" do
            expect(new_absorbing_organisation.owned_schemes.count).to eq(2)
            absorbed_active_scheme = new_absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name)
            absorbed_active_location = absorbed_active_scheme.locations.find_by(postcode: location.postcode)
            expect(absorbed_active_scheme.service_name).to eq(scheme.service_name)
            expect(absorbed_active_scheme.old_id).to be_nil
            expect(absorbed_active_scheme.old_visible_id).to be_nil
            expect(absorbed_active_scheme.locations.count).to eq(2)
            expect(absorbed_active_location.postcode).to eq(location.postcode)
            expect(absorbed_active_location.old_id).to be_nil
            expect(absorbed_active_location.old_visible_id).to be_nil
          end

          it "deactivates active schemes and locations on merging organisation" do
            expect(scheme.scheme_deactivation_periods.count).to eq(1)
            expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today)
            expect(scheme.locations.find_by(postcode: location.postcode).location_deactivation_periods.count).to eq(1)
            expect(scheme.locations.find_by(postcode: location.postcode).location_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.today)
          end

          it "does not deactivate inactive locations on merging organisation again" do
            expect(scheme.locations.find_by(postcode: deactivated_location.postcode).location_deactivation_periods.count).to eq(1)
          end

          it "moves inactive schemes and their locations to absorbing organisation" do
            absorbed_inactive_scheme = new_absorbing_organisation.owned_schemes.find_by(service_name: deactivated_scheme.service_name)
            expect(absorbed_inactive_scheme.scheme_deactivation_periods.count).to eq(1)
            expect(absorbed_inactive_scheme.scheme_deactivation_periods.first.deactivation_date).to eq(merging_organisation.merge_date)
            expect(absorbed_inactive_scheme.locations.count).to eq(1)
            expect(absorbed_inactive_scheme.locations.first.location_deactivation_periods.count).to eq(0)
            expect(deactivated_scheme.scheme_deactivation_periods.count).to eq(1)
          end

          it "moves inactive locations of active schemes to absorbing organisation" do
            absorbed_active_scheme = new_absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name)
            absorbed_inactive_location = absorbed_active_scheme.locations.find_by(postcode: deactivated_location.postcode)
            expect(absorbed_active_scheme.scheme_deactivation_periods.count).to eq(0)
            expect(absorbed_inactive_location.location_deactivation_periods.count).to eq(1)
            expect(absorbed_inactive_location.location_deactivation_periods.first.deactivation_date).to eq(merging_organisation.merge_date)
          end
        end

        it "moves relevant logs and assigns the new scheme" do
          merge_organisations_service.call

          new_absorbing_organisation.reload
          merging_organisation.reload
          expect(new_absorbing_organisation.owned_lettings_logs.count).to eq(2)
          expect(new_absorbing_organisation.managed_lettings_logs.count).to eq(1)
          expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).scheme).to eq(new_absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name))
          expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log.id).location).to eq(new_absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name).locations.first)
          expect(new_absorbing_organisation.owned_lettings_logs.find(owned_lettings_log_no_location.id).scheme).to eq(new_absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name))
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
          let!(:owned_lettings_log) { create(:lettings_log, startdate: Time.zone.today, owning_organisation: merging_organisation, assigned_to: merging_organisation_user) }
          let!(:managed_lettings_log) { create(:lettings_log, startdate: Time.zone.today) }

          before do
            create(:organisation_relationship) { create(:organisation_relationship, parent_organisation: owning_organisation, child_organisation: merging_organisation) }
            managed_lettings_log.update!(owning_organisation:, managing_organisation: merging_organisation, assigned_to: merging_organisation_user)
            create(:lettings_log, startdate: Time.zone.today - 2.days, owning_organisation: merging_organisation, assigned_to: merging_organisation_user)
            create(:lettings_log, startdate: Time.zone.today - 2.days, owning_organisation:, managing_organisation: merging_organisation, assigned_to: merging_organisation_user)
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

          it "logs the merged schemes" do
            expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
            expect(Rails.logger).to receive(:info).with("\t#{merging_organisation.data_protection_officers.first.name} (#{merging_organisation.data_protection_officers.first.email})")
            expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
            expect(Rails.logger).to receive(:info).with("New schemes from fake org:")
            expect(Rails.logger).to receive(:info).with(/\t#{scheme.service_name} \(S/)
            expect(Rails.logger).to receive(:info).with(/\t#{deactivated_scheme.service_name} \(S/)
            merge_organisations_service.call
          end

          context "when combining organisation schemes and locations" do
            before do
              merge_organisations_service.call
              new_absorbing_organisation.reload
              deactivated_scheme.reload
              deactivated_location.reload
              merging_organisation.reload
            end

            it "moves active schemes and locations to absorbing organisation" do
              expect(new_absorbing_organisation.owned_schemes.count).to eq(2)

              absorbed_active_scheme = new_absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name)
              absorbed_active_location = absorbed_active_scheme.locations.find_by(postcode: location.postcode)
              expect(absorbed_active_scheme.service_name).to eq(scheme.service_name)
              expect(absorbed_active_scheme.old_id).to be_nil
              expect(absorbed_active_scheme.old_visible_id).to be_nil
              expect(absorbed_active_scheme.locations.count).to eq(2)
              expect(absorbed_active_location.postcode).to eq(location.postcode)
              expect(absorbed_active_location.old_id).to be_nil
              expect(absorbed_active_location.old_visible_id).to be_nil
            end

            it "deactivates active schemes and locations on merging organisation" do
              expect(scheme.scheme_deactivation_periods.count).to eq(1)
              expect(scheme.scheme_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.yesterday)
              expect(scheme.locations.find_by(postcode: location.postcode).location_deactivation_periods.count).to eq(1)
              expect(scheme.locations.find_by(postcode: location.postcode).location_deactivation_periods.first.deactivation_date.to_date).to eq(Time.zone.yesterday)
            end

            it "does not deactivate inactive locations on merging organisation again" do
              expect(scheme.locations.find_by(postcode: deactivated_location.postcode).location_deactivation_periods.count).to eq(1)
            end

            it "moves inactive schemes and their locations to absorbing organisation" do
              absorbed_inactive_scheme = new_absorbing_organisation.owned_schemes.find_by(service_name: deactivated_scheme.service_name)
              expect(absorbed_inactive_scheme.scheme_deactivation_periods.count).to eq(1)
              expect(absorbed_inactive_scheme.scheme_deactivation_periods.first.deactivation_date).to eq(merging_organisation.merge_date)
              expect(absorbed_inactive_scheme.locations.count).to eq(1)
              expect(absorbed_inactive_scheme.locations.first.location_deactivation_periods.count).to eq(0)
              expect(deactivated_scheme.scheme_deactivation_periods.count).to eq(1)
            end

            it "moves inactive locations of active schemes to absorbing organisation" do
              absorbed_active_scheme = new_absorbing_organisation.owned_schemes.find_by(service_name: scheme.service_name)
              absorbed_inactive_location = absorbed_active_scheme.locations.find_by(postcode: deactivated_location.postcode)
              expect(absorbed_active_scheme.scheme_deactivation_periods.count).to eq(0)
              expect(absorbed_inactive_location.location_deactivation_periods.count).to eq(1)
              expect(absorbed_inactive_location.location_deactivation_periods.first.deactivation_date).to eq(merging_organisation.merge_date)
            end
          end

          it "moves relevant logs and assigns the new scheme" do
            merge_organisations_service.call

            new_absorbing_organisation.reload
            merging_organisation.reload
            owned_lettings_log_no_location.reload
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
        create_list(:user, 5, organisation: merging_organisation_too, name: "Danny Rojas")
      end

      it "moves the users from merging organisations to absorbing organisation" do
        expect(Rails.logger).to receive(:info).with("Merged users from fake org:")
        expect(Rails.logger).to receive(:info).with("\t#{merging_organisation.data_protection_officers.first.name} (#{merging_organisation.data_protection_officers.first.email})")
        expect(Rails.logger).to receive(:info).with("\tfake name (fake@email.com)")
        expect(Rails.logger).to receive(:info).with("Merged users from second org:")
        expect(Rails.logger).to receive(:info).with(/\tDanny Rojas/).exactly(5).times
        expect(Rails.logger).to receive(:info).with(/\t#{merging_organisation_too.data_protection_officers.first.name}/)
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

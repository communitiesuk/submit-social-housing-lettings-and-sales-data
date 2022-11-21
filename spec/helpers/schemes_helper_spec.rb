  require "rails_helper"

  include TagHelper

  RSpec.describe SchemesHelper do
  describe "Active periods" do
    let(:scheme) { FactoryBot.create(:scheme, created_at: Time.zone.today) }

    before do
      Timecop.freeze(2022, 10, 10)
    end

    after do
      Timecop.unfreeze
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

    describe "display_scheme_attributes" do
      let (owning
      let!(:scheme) { FactoryBot.create(:scheme, 
        id: 1,
        created_at: Time.zone.local(2022, 4, 1),
        service_name: 'Test name'
        owning_organisation
        ) }
      let(:support_user) { FactoryBot.create(:user, :support) }
      let(:coordinator_user) { FactoryBot.create(:user, :data_coordinator) }

      it "returns correct display attributes for a support user" do
        attributes = [
          { name: "Scheme code", value: "S1" },
          { name: "Name", value: "Test name", edit: true },
          { name: "Confidential information", value: scheme.sensitive, edit: true },
          { name: "Type of scheme", value: scheme.scheme_type },
          { name: "Registered under Care Standards Act 2000", value: scheme.registered_under_care_act },
          { name: "Housing stock owned by", value: ""scheme.owning_organisation.name"", edit: true },
          { name: "Support services provided by", value: scheme.arrangement_type },
          { name: "Primary client group", value: scheme.primary_client_group },
          { name: "Has another client group", value: scheme.has_other_client_group },
          { name: "Secondary client group", value: scheme.secondary_client_group },
          { name: "Level of support given", value: scheme.support_type },
          { name: "Intended length of stay", value: scheme.intended_stay },
          { name: "Availability", value: "Active from 1 April 2022" },
          { name: "Status", value: status_tag(:active) },
        ]
        expect(display_scheme_attributes(scheme, support_user)).to eq(attributes)
      end

      it "returns correct display attributes for a coordinator user" do
        attributes = [
          { name: "Scheme code", value: scheme.id_to_display },
          { name: "Name", value: scheme.service_name, edit: true },
          { name: "Confidential information", value: scheme.sensitive, edit: true },
          { name: "Type of scheme", value: scheme.scheme_type },
          { name: "Registered under Care Standards Act 2000", value: scheme.registered_under_care_act },
          { name: "Support services provided by", value: scheme.arrangement_type },
          { name: "Primary client group", value: scheme.primary_client_group },
          { name: "Has another client group", value: scheme.has_other_client_group },
          { name: "Secondary client group", value: scheme.secondary_client_group },
          { name: "Level of support given", value: scheme.support_type },
          { name: "Intended length of stay", value: scheme.intended_stay },
          { name: "Availability", value: "Active from 1 April 2022" },
          { name: "Status", value: status_tag(:active) },
        ]
        expect(display_scheme_attributes(scheme, coordinator_user)).to eq(attributes)
      end

    context "when viewing availability" do
      context "with no deactivations" do
        it "displays created_at as availability date" do
          availability_attribute = display_scheme_attributes(scheme, support_user).find { |x| x[:name] == "Availability" }[:value]

          expect(availability_attribute).to eq("Active from #{scheme.created_at.to_formatted_s(:govuk_date)}")
        end

        it "displays current collection start date as availability date if created_at is later than collection start date" do
          scheme.update!(created_at: Time.zone.local(2022, 4, 16))
          availability_attribute = display_scheme_attributes(scheme).find { |x| x[:name] == "Availability" }[:value]

          expect(availability_attribute).to eq("Active from 1 April 2022")
        end
      end

      context "with previous deactivations" do
        context "and all reactivated deactivations" do
          before do
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 10), reactivation_date: Time.zone.local(2022, 9, 1), scheme:)
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 15), reactivation_date: Time.zone.local(2022, 9, 28), scheme:)
            scheme.reload
          end

          it "displays the timeline of availability" do
            availability_attribute = display_scheme_attributes(scheme).find { |x| x[:name] == "Availability" }[:value]

            expect(availability_attribute).to eq("Active from 1 April 2022 to 9 August 2022\nDeactivated on 10 August 2022\nActive from 1 September 2022 to 14 September 2022\nDeactivated on 15 September 2022\nActive from 28 September 2022")
          end
        end

        context "and non reactivated deactivation" do
          before do
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 10), reactivation_date: Time.zone.local(2022, 9, 1), scheme:)
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 15), reactivation_date: nil, scheme:)
            scheme.reload
          end

          it "displays the timeline of availability" do
            availability_attribute = display_scheme_attributes(scheme).find { |x| x[:name] == "Availability" }[:value]

            expect(availability_attribute).to eq("Active from 1 April 2022 to 9 August 2022\nDeactivated on 10 August 2022\nActive from 1 September 2022 to 14 September 2022\nDeactivated on 15 September 2022")
          end
        end
      end

      context "with out of order deactivations" do
        context "and all reactivated deactivations" do
          before do
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 24), reactivation_date: Time.zone.local(2022, 9, 28), scheme:)
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 15), reactivation_date: Time.zone.local(2022, 6, 18), scheme:)
            scheme.reload
          end

          it "displays the timeline of availability" do
            availability_attribute = display_scheme_attributes(scheme).find { |x| x[:name] == "Availability" }[:value]

            expect(availability_attribute).to eq("Active from 1 April 2022 to 14 June 2022\nDeactivated on 15 June 2022\nActive from 18 June 2022 to 23 September 2022\nDeactivated on 24 September 2022\nActive from 28 September 2022")
          end
        end

        context "and one non reactivated deactivation" do
          before do
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 24), reactivation_date: Time.zone.local(2022, 9, 28), scheme:)
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 15), reactivation_date: nil, scheme:)
            scheme.reload
          end

          it "displays the timeline of availability" do
            availability_attribute = display_scheme_attributes(scheme).find { |x| x[:name] == "Availability" }[:value]

            expect(availability_attribute).to eq("Active from 1 April 2022 to 14 June 2022\nDeactivated on 15 June 2022\nActive from 28 September 2022")
          end
        end
      end

      context "with multiple out of order deactivations" do
        context "and one non reactivated deactivation" do
          before do
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 24), reactivation_date: Time.zone.local(2022, 9, 28), scheme:)
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 10, 24), reactivation_date: Time.zone.local(2022, 10, 28), scheme:)
            FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 6, 15), reactivation_date: nil, scheme:)
            scheme.reload
          end

          it "displays the timeline of availability" do
            availability_attribute = display_scheme_attributes(scheme).find { |x| x[:name] == "Availability" }[:value]

            expect(availability_attribute).to eq("Active from 1 April 2022 to 14 June 2022\nDeactivated on 15 June 2022\nActive from 28 September 2022 to 23 October 2022\nDeactivated on 24 October 2022\nActive from 28 October 2022")
          end
        end
      end

      context "with intersecting deactivations" do
        before do
          FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 10, 10), reactivation_date: Time.zone.local(2022, 12, 1), scheme:)
          FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 11, 11), reactivation_date: Time.zone.local(2022, 12, 11), scheme:)
          scheme.reload
        end

        it "displays the timeline of availability" do
          availability_attribute = display_scheme_attributes(scheme, support_user).find { |x| x[:name] == "Availability" }[:value]

          expect(availability_attribute).to eq("Active from 1 April 2022 to 9 October 2022\nDeactivated on 10 October 2022\nActive from 11 December 2022")
        end
      end
    end
  end
end

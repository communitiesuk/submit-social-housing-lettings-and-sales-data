require "rails_helper"

RSpec.describe SchemesHelper do
  describe "display_scheme_attributes" do
    let!(:scheme) { FactoryBot.create(:scheme, created_at: Time.zone.local(2022, 8, 8)) }

    it "returns correct display attributes" do
      attributes = [
        { name: "Scheme code", value: scheme.id_to_display },
        { name: "Name", value: scheme.service_name, edit: true },
        { name: "Confidential information", value: scheme.sensitive, edit: true },
        { name: "Type of scheme", value: scheme.scheme_type },
        { name: "Registered under Care Standards Act 2000", value: scheme.registered_under_care_act },
        { name: "Housing stock owned by", value: scheme.owning_organisation.name, edit: true },
        { name: "Support services provided by", value: scheme.arrangement_type },
        { name: "Primary client group", value: scheme.primary_client_group },
        { name: "Has another client group", value: scheme.has_other_client_group },
        { name: "Secondary client group", value: scheme.secondary_client_group },
        { name: "Level of support given", value: scheme.support_type },
        { name: "Intended length of stay", value: scheme.intended_stay },
        { name: "Availability", value: "Active from 8 August 2022" },
        { name: "Status", value: :active },
      ]
      expect(display_scheme_attributes(scheme)).to eq(attributes)
    end

    context "when viewing availability" do
      context "with are no deactivations" do
        it "displays created_at as availability date" do
          availability_attribute = display_scheme_attributes(scheme).find { |x| x[:name] == "Availability" }[:value]

          expect(availability_attribute).to eq("Active from #{scheme.created_at.to_formatted_s(:govuk_date)}")
        end
      end

      context "with previous deactivations" do
        before do
          scheme.scheme_deactivation_periods << FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 8, 10), reactivation_date: Time.zone.local(2022, 9, 1))
          scheme.scheme_deactivation_periods << FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.local(2022, 9, 15), reactivation_date: nil)
        end

        it "displays the timeline of availability" do
          availability_attribute = display_scheme_attributes(scheme).find { |x| x[:name] == "Availability" }[:value]

          expect(availability_attribute).to eq("Active from 8 August 2022 to 9 August 2022\nDeactivated on 10 August 2022\nActive from 1 September 2022 to 14 September 2022\nDeactivated on 15 September 2022")
        end
      end
    end
  end
end

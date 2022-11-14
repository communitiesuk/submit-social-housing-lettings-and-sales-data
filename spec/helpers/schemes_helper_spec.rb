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
        { name: "Availability", value: "Available from 8 August 2022" },
        { name: "Status", value: :active },
      ]
      expect(display_scheme_attributes(scheme)).to eq(attributes)
    end
  end
end

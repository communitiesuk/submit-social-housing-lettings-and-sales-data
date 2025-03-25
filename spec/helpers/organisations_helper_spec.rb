require "rails_helper"

RSpec.describe OrganisationsHelper do
  include TagHelper
  describe "display_organisation_attributes" do
    let(:support_user) { create(:user, :support) }
    let(:coordinator_user) { create(:user, :data_coordinator) }
    let(:organisation) { create(:organisation, :la, :holds_own_stock, address_line1: "2 Marsham Street", address_line2: "London", postcode: "SW1P 4DF", housing_registration_no: 1234, organisation_rent_periods: [], group_member: true, group_member_id: 99, group: 1) }

    it "has the correct values and editable status for support users" do
      expect(display_organisation_attributes(support_user, organisation)).to eq(
        [{ editable: false, name: "Organisation ID", value: "ORG#{organisation.id}" },
         { editable: true,
           name: "Address",
           value: "2 Marsham Street\nLondon\nSW1P 4DF" },
         { editable: true, name: "Telephone number", value: nil },
         { editable: false, name: "Registration number", value: "1234" },
         { editable: false, name: "Type of provider", value: "Local authority" },
         { editable: false, name: "Owns housing stock", value: "Yes" },
         { editable: true, name: "Part of group", value: "Yes" },
         { editable: true, name: "Group number", value: "GROUP1" },
         { editable: true, name: "For profit", value: "" },
         { editable: true, format: :bullet, name: "Rent periods", value: [] },
         { name: "Data Sharing Agreement" },
         { editable: false, name: "Status", value: status_tag(organisation.status) }],
      )
    end

    it "has the correct values and editable status for non-support users" do
      expect(display_organisation_attributes(coordinator_user, organisation)).to eq(
        [{ editable: false, name: "Organisation ID", value: "ORG#{organisation.id}" },
         { editable: true,
           name: "Address",
           value: "2 Marsham Street\nLondon\nSW1P 4DF" },
         { editable: true, name: "Telephone number", value: nil },
         { editable: false, name: "Registration number", value: "1234" },
         { editable: false, name: "Type of provider", value: "Local authority" },
         { editable: false, name: "Owns housing stock", value: "Yes" },
         { editable: false, name: "Part of group", value: "Yes" },
         { editable: false, name: "Group number", value: "GROUP1" },
         { editable: false, name: "For profit", value: "" },
         { editable: true, format: :bullet, name: "Rent periods", value: [] },
         { name: "Data Sharing Agreement" },
         { editable: false, name: "Status", value: status_tag(organisation.status) }],
      )
    end
  end

  describe "rent_periods_with_checked_attr" do
    let(:fake_rent_periods) do
      {
        "1" => { "value" => "Every minute" },
        "2" => { "value" => "Every decade" },
      }
    end

    before do
      allow(RentPeriod).to receive(:rent_period_mappings).and_return fake_rent_periods
    end

    it "returns rent_period_mappings" do
      actual = rent_periods_with_checked_attr
      expect(actual.keys).to eq RentPeriod.rent_period_mappings.keys
    end

    context "when checked_periods is nil" do
      it "returns all rent periods with checked true" do
        actual = rent_periods_with_checked_attr
        checked_attrs = actual.values.map { |p| p[:checked] }
        expect(checked_attrs).to all be true
      end
    end

    context "when checked_periods is not nil" do
      it "returns the rent_periods with the correct values checked" do
        checked_rent_period = "1"
        actual = rent_periods_with_checked_attr(checked_periods: [checked_rent_period])
        expect(actual[checked_rent_period][:checked]).to be true
        expect(actual["2"][:checked]).to be_falsey
      end
    end
  end
end

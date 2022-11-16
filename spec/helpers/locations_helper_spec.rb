require "rails_helper"

RSpec.describe LocationsHelper do
  describe "mobility type selection" do
    expected_selection = [OpenStruct.new(id: "Wheelchair-user standard", name: "Wheelchair-user standard", description: "The majority of units are suitable for someone who uses a wheelchair and offer the full use of all rooms and facilities."),
                          OpenStruct.new(id: "Fitted with equipment and adaptations", name: "Fitted with equipment and adaptations", description: "For example, the majority of units have been fitted with stairlifts, ramps, level access showers or grab rails."),
                          OpenStruct.new(id: "None", name: "None", description: "The majority of units are not designed to wheelchair-user standards or fitted with any equipment and adaptations.")]
    it "returns correct selection to display" do
      expect(mobility_type_selection).to eq(expected_selection)
    end
  end

  describe "another location selection" do
    it "returns correct selection to display" do
      expected_selection = [OpenStruct.new(id: "Yes", name: "Yes"), OpenStruct.new(id: "No", name: "No")]
      expect(another_location_selection).to eq(expected_selection)
    end
  end

  describe "type of units selection" do
    it "returns correct selection to display" do
      expected_selection = [OpenStruct.new(id: "Bungalow", name: "Bungalow"),
                            OpenStruct.new(id: "Self-contained flat or bedsit", name: "Self-contained flat or bedsit"),
                            OpenStruct.new(id: "Self-contained flat or bedsit with common facilities", name: "Self-contained flat or bedsit with common facilities"),
                            OpenStruct.new(id: "Self-contained house", name: "Self-contained house"),
                            OpenStruct.new(id: "Shared flat", name: "Shared flat"),
                            OpenStruct.new(id: "Shared house or hostel", name: "Shared house or hostel")]
      expect(type_of_units_selection).to eq(expected_selection)
    end
  end

  describe "selection options" do
    it "returns empty array for nil" do
      expect(selection_options(nil)).to eq([])
    end

    it "returns empty array for empty string" do
      expect(selection_options("")).to eq([])
    end

    it "returns empty array for empty object" do
      expect(selection_options({})).to eq([])
    end

    it "can map a resource with values" do
      expect(selection_options(%w[example])).to eq([OpenStruct.new(id: "example", name: "Example")])
    end
  end

  describe "display_location_attributes" do
    let(:location) { FactoryBot.build(:location, startdate: Time.zone.local(2022, 8, 8)) }

    it "returns correct display attributes" do
      attributes = [
        { name: "Postcode", value: location.postcode },
        { name: "Local authority", value: location.location_admin_district },
        { name: "Location name", value: location.name, edit: true },
        { name: "Total number of units at this location", value: location.units },
        { name: "Common type of unit", value: location.type_of_unit },
        { name: "Mobility type", value: location.mobility_type },
        { name: "Code", value: location.location_code },
        { name: "Availability", value: "Available from 8 August 2022" },
        { name: "Status", value: :active },
      ]

      expect(display_location_attributes(location)).to eq(attributes)
    end

    it "displays created_at as availability date if startdate is not present" do
      location.update!(startdate: nil)
      availability_attribute = display_location_attributes(location).find { |x| x[:name] == "Availability" }[:value]

      expect(availability_attribute).to eq("Available from #{location.created_at.to_formatted_s(:govuk_date)}")
    end
  end
end

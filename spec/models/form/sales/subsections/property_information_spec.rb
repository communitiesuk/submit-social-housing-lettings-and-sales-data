require "rails_helper"

RSpec.describe Form::Sales::Subsections::PropertyInformation, type: :model do
  subject(:property_information) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::PropertyInformation) }

  it "has correct section" do
    expect(property_information.section).to eq(section)
  end

  it "has correct pages" do
    expect(property_information.pages.map(&:id)).to eq(
      %w[
        property_number_of_bedrooms
        property_building_type
        property_unit_type
        postcode_known
        property_local_authority
      ],
    )
  end

  it "has the correct id" do
    expect(property_information.id).to eq("property_information")
  end

  it "has the correct label" do
    expect(property_information.label).to eq("Property information")
  end
end

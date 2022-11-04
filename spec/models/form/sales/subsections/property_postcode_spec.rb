require "rails_helper"

RSpec.describe Form::Sales::Subsections::PropertyPostcode, type: :model do
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
        postcode_known
      ],
    )
  end

  it "has the correct id" do
    expect(property_information.id).to eq("property_postcode")
  end

  it "has the correct label" do
    expect(property_information.label).to eq("Property postcode")
  end
end

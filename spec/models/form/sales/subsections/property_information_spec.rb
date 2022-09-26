require "rails_helper"

RSpec.describe Form::Sales::Subsections::PropertyInformation, type: :model do
  subject(:setup) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::PropertyInformation) }

  it "has correct section" do
    expect(setup.section).to eq(section)
  end

  it "has correct pages" do
    expect(setup.pages.map(&:id)).to eq(
      %w[property_number_of_bedrooms],
    )
  end

  it "has the correct id" do
    expect(setup.id).to eq("property_information")
  end

  it "has the correct label" do
    expect(setup.label).to eq("Property information")
  end
end

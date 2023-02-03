require "rails_helper"

RSpec.describe Form::Lettings::Subsections::TenancyInformation, type: :model do
  subject(:tenancy_information) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Lettings::Sections::TenancyAndProperty) }

  it "has correct section" do
    expect(tenancy_information.section).to eq(section)
  end

  it "has correct pages" do
    expect(tenancy_information.pages.map(&:id)).to eq(
      %w[joint starter_tenancy tenancy_type starter_tenancy_type tenancy_length shelteredaccom],
    )
  end

  it "has the correct id" do
    expect(tenancy_information.id).to eq("tenancy_information")
  end

  it "has the correct label" do
    expect(tenancy_information.label).to eq("Tenancy information")
  end

  it "has the correct depends_on" do
    expect(tenancy_information.depends_on).to eq([
      {
        "non_location_setup_questions_completed?" => true,
      },
    ])
  end
end

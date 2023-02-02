require "rails_helper"

RSpec.describe Form::Lettings::Subsections::PropertyInformation, type: :model do
  subject(:property_information) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Lettings::Sections::TenancyAndProperty) }

  it "has correct section" do
    expect(property_information.section).to eq(section)
  end

  it "has correct pages" do
    expect(property_information.pages.map(&:id)).to eq(
      %w[
        property_postcode
        property_local_authority
        first_time_property_let_as_social_housing
        property_let_type
        property_vacancy_reason_not_first_let
        property_vacancy_reason_first_let
        property_number_of_times_relet_not_social_let
        property_number_of_times_relet_social_let
        property_unit_type
        property_building_type
        property_wheelchair_accessible
        property_number_of_bedrooms
        void_or_renewal_date
        void_date_value_check
        new_build_handover_date
        property_major_repairs
        property_major_repairs_value_check
      ],
    )
  end

  it "has the correct id" do
    expect(property_information.id).to eq("property_information")
  end

  it "has the correct label" do
    expect(property_information.label).to eq("Property information")
  end

  it "has the correct depends_on" do
    expect(property_information.depends_on).to eq([
      {
        "non_location_setup_questions_completed?" => true,
      },
    ])
  end
end

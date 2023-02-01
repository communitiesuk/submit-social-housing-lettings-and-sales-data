require "rails_helper"

RSpec.describe Form::Lettings::Subsections::HouseholdNeeds, type: :model do
  subject(:household_needs) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Lettings::Sections::Household) }

  it "has correct section" do
    expect(household_needs.section).to eq(section)
  end

  it "has correct pages" do
    expect(household_needs.pages.map(&:id)).to eq(
      %w[armed_forces
         armed_forces_serving
         armed_forces_injured
         pregnant
         no_females_pregnant_household_value_check
         females_in_soft_age_range_in_pregnant_household_value_check
         access_needs_exist
         type_of_access_needs
         health_conditions
         health_condition_effects],
    )
  end

  it "has the correct id" do
    expect(household_needs.id).to eq("household_needs")
  end

  it "has the correct label" do
    expect(household_needs.label).to eq("Household needs")
  end

  it "has the correct depends_on" do
    expect(household_needs.depends_on).to eq([
      {
        "non_location_setup_questions_completed?" => true,
      },
    ])
  end
end

require "rails_helper"

RSpec.describe Form::Lettings::Subsections::HouseholdNeeds, type: :model do
  subject(:household_needs) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }
  let(:section) { instance_double(Form::Lettings::Sections::Household, form:) }

  before do
    allow(form).to receive(:start_year_2025_or_later?).and_return(false)
    allow(form).to receive(:start_year_2026_or_later?).and_return(false)
  end

  it "has correct section" do
    expect(household_needs.section).to eq(section)
  end

  context "with start year >= 2025", metadata: { year: 25 } do
    before do
      allow(form).to receive(:start_year_2025_or_later?).and_return(true)
    end

    it "has correct pages" do
      expect(household_needs.pages.map(&:id)).to eq(
        %w[
          armed_forces
          armed_forces_serving
          armed_forces_injured
          pregnant
          no_females_pregnant_household_value_check
          females_in_soft_age_range_in_pregnant_household_value_check
          access_needs_exist
          type_of_access_needs
          health_conditions
          health_condition_effects
        ],
      )
    end
  end

  context "with start year >= 2026", metadata: { year: 26 } do
    before do
      allow(form).to receive(:start_year_2025_or_later?).and_return(true)
      allow(form).to receive(:start_year_2026_or_later?).and_return(true)
    end

    it "has correct pages" do
      expect(household_needs.pages.map(&:id)).to eq(
        %w[
          armed_forces
          armed_forces_serving
          armed_forces_injured
          pregnant
          no_household_member_likely_to_be_pregnant_check
          access_needs_exist
          type_of_access_needs
          health_conditions
          working_situation_long_term_illness_check
          health_condition_effects
        ],
      )
    end
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

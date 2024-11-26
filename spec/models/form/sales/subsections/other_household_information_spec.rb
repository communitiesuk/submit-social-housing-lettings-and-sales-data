require "rails_helper"

RSpec.describe Form::Sales::Subsections::OtherHouseholdInformation, type: :model do
  subject(:household_characteristics) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }

  context "when 2024" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_2025_or_later?: false) }
    let(:section) { instance_double(Form::Sales::Sections::Household, form:) }

    it "has correct section" do
      expect(household_characteristics.section).to eq(section)
    end

    it "has correct pages" do
      expect(household_characteristics.pages.map(&:id)).to eq(
        %w[
          armed_forces
          buyer_still_serving
          armed_forces_spouse
          household_disability
          disability_wheelchair_check
          household_wheelchair
          wheelchair_check
        ],
      )
    end

    it "has the correct id" do
      expect(household_characteristics.id).to eq("other_household_information")
    end

    it "has the correct label" do
      expect(household_characteristics.label).to eq("Other household information")
    end

    it "has correct depends on" do
      expect(household_characteristics.depends_on).to eq([{ "setup_completed?" => true }])
    end
  end

  context "when 2025" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2025, 4, 1), start_year_2025_or_later?: true) }
    let(:section) { instance_double(Form::Sales::Sections::Household, form:) }

    it "has correct depends on" do
      expect(household_characteristics.depends_on).to eq([{ "setup_completed?" => true, "is_staircase?" => false }])
    end
  end
end

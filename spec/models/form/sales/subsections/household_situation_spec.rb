require "rails_helper"

RSpec.describe Form::Sales::Subsections::HouseholdSituation, type: :model do
  subject(:household_characteristics) { described_class.new(nil, nil, section) }

  let(:form) { instance_double(Form, start_year_2024_or_later?: true, start_year_2025_or_later?: false) }
  let(:section) { instance_double(Form::Sales::Sections::Household, form:) }

  it "has correct section" do
    expect(household_characteristics.section).to eq(section)
  end

  context "when the start year is 2024" do
    let(:form) { instance_double(Form, start_year_2024_or_later?: true, start_year_2025_or_later?: false) }

    it "has correct pages" do
      expect(household_characteristics.pages.map(&:id)).to eq(
        %w[
          buyer1_previous_tenure
          last_accommodation
          last_accommodation_la
          buyers_organisations
          buyer_2_living_in
          buyer_2_previous_housing_situation
        ],
      )
    end
  end

  context "when the start year is 2025" do
    let(:form) { instance_double(Form, start_year_2024_or_later?: true, start_year_2025_or_later?: true) }

    it "has correct pages" do
      expect(household_characteristics.pages.map(&:id)).to eq(
        %w[
          buyer1_previous_tenure
          last_accommodation
          last_accommodation_la
          buyer_2_living_in
          buyer_2_previous_housing_situation
        ],
      )
    end
  end

  it "has the correct id" do
    expect(household_characteristics.id).to eq("household_situation")
  end

  it "has the correct label" do
    expect(household_characteristics.label).to eq("Household situation")
  end

  it "has correct depends on" do
    expect(household_characteristics.depends_on).to eq([{ "setup_completed?" => true }])
  end
end

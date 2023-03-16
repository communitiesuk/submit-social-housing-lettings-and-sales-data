require "rails_helper"

RSpec.describe Form::Sales::Subsections::HouseholdSituation, type: :model do
  subject(:household_characteristics) { described_class.new(nil, nil, section) }

  let(:start_date) { Time.utc(2023, 4, 1) }
  let(:form) { instance_double(Form, start_date:) }
  let(:section) { instance_double(Form::Sales::Sections::Household, form:) }

  it "has correct section" do
    expect(household_characteristics.section).to eq(section)
  end

  context "when the log belongs to the 22/23 collection" do
    let(:start_date) { Time.utc(2022, 4, 1) }

    it "has correct pages" do
      expect(household_characteristics.pages.map(&:id)).to eq(
        %w[
          buyer1_previous_tenure
          last_accommodation
          last_accommodation_la
          buyers_organisations
        ],
      )
    end
  end

  context "when the log belongs to the 23/24 collection" do
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

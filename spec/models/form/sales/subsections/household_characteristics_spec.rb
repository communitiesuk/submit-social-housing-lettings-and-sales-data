require "rails_helper"

RSpec.describe Form::Sales::Subsections::HouseholdCharacteristics, type: :model do
  subject(:household_characteristics) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::Household) }

  it "has correct section" do
    expect(household_characteristics.section).to eq(section)
  end

  it "has correct pages" do
    expect(household_characteristics.pages.map(&:id)).to eq(
      %w[
        buyer_interview
        privacy_notice
        buyer_1_age
        buyer_1_gender_identity
        buyer_1_ethnic_group
        buyer_1_ethnic_background_black
        buyer_1_ethnic_background_asian
        buyer_1_ethnic_background_arab
        buyer_1_ethnic_background_mixed
        buyer_1_ethnic_background_white
        buyer_1_nationality
        buyer_1_working_situation
        buyer_1_live_in_property
        buyer_2_relationship_to_buyer_1
        buyer_2_age
        buyer_2_gender_identity
        buyer_2_working_situation
        buyer_2_live_in_property
        number_of_others_in_property
        person_1_age
        person_1_gender_identity
        person_1_gender_identity
        person_2_known
        person_2_age
        person_3_known
        person_3_age
        person_4_known
        person_4_age
      ],
    )
  end

  it "has the correct id" do
    expect(household_characteristics.id).to eq("household_characteristics")
  end

  it "has the correct label" do
    expect(household_characteristics.label).to eq("Household characteristics")
  end

  it "has correct depends on" do
    expect(household_characteristics.depends_on).to eq([{ "setup_completed?" => true }])
  end
end

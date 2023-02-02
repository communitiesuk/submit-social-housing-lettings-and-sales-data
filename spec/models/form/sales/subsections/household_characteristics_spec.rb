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
        age_1_retirement_value_check
        age_1_retirement_value_check_joint_purchase
        age_1_old_persons_shared_ownership_value_check
        buyer_1_gender_identity
        gender_1_retirement_value_check
        gender_1_retirement_value_check_joint_purchase
        buyer_1_ethnic_group
        buyer_1_ethnic_background_black
        buyer_1_ethnic_background_asian
        buyer_1_ethnic_background_arab
        buyer_1_ethnic_background_mixed
        buyer_1_ethnic_background_white
        buyer_1_nationality
        buyer_1_working_situation
        working_situation_1_retirement_value_check
        working_situation_1_retirement_value_check_joint_purchase
        working_situation_buyer_1_income_value_check
        buyer_1_live_in_property
        buyer_2_relationship_to_buyer_1
        buyer_2_age
        age_2_retirement_value_check_joint_purchase
        age_2_old_persons_shared_ownership_value_check
        buyer_2_gender_identity
        gender_2_retirement_value_check_joint_purchase
        buyer_2_working_situation
        working_situation_2_retirement_value_check_joint_purchase
        buyer_2_live_in_property
        number_of_others_in_property
        person_1_known
        person_1_known_joint_purchase
        person_1_relationship_to_buyer_1
        person_1_relationship_to_buyer_1_joint_purchase
        person_1_age
        age_2_retirement_value_check
        person_1_age_joint_purchase
        age_3_retirement_value_check_joint_purchase
        person_1_gender_identity
        gender_2_retirement_value_check
        person_1_gender_identity_joint_purchase
        gender_3_retirement_value_check_joint_purchase
        person_1_working_situation
        working_situation_2_retirement_value_check
        person_1_working_situation_joint_purchase
        working_situation_3_retirement_value_check_joint_purchase
        person_2_known
        person_2_known_joint_purchase
        person_2_relationship_to_buyer_1
        person_2_relationship_to_buyer_1_joint_purchase
        person_2_age
        age_3_retirement_value_check
        person_2_age_joint_purchase
        age_4_retirement_value_check_joint_purchase
        person_2_gender_identity
        gender_3_retirement_value_check
        person_2_gender_identity_joint_purchase
        gender_4_retirement_value_check_joint_purchase
        person_2_working_situation
        working_situation_3_retirement_value_check
        person_2_working_situation_joint_purchase
        working_situation_4_retirement_value_check_joint_purchase
        person_3_known
        person_3_known_joint_purchase
        person_3_relationship_to_buyer_1
        person_3_relationship_to_buyer_1_joint_purchase
        person_3_age
        age_4_retirement_value_check
        person_3_age_joint_purchase
        age_5_retirement_value_check_joint_purchase
        person_3_gender_identity
        gender_4_retirement_value_check
        person_3_gender_identity_joint_purchase
        gender_5_retirement_value_check_joint_purchase
        person_3_working_situation
        working_situation_4_retirement_value_check
        person_3_working_situation_joint_purchase
        working_situation_5_retirement_value_check_joint_purchase
        person_4_known
        person_4_known_joint_purchase
        person_4_relationship_to_buyer_1
        person_4_relationship_to_buyer_1_joint_purchase
        person_4_age
        age_5_retirement_value_check
        person_4_age_joint_purchase
        age_6_retirement_value_check_joint_purchase
        person_4_gender_identity
        gender_5_retirement_value_check
        person_4_gender_identity_joint_purchase
        gender_6_retirement_value_check_joint_purchase
        person_4_working_situation
        working_situation_5_retirement_value_check
        person_4_working_situation_joint_purchase
        working_situation_6_retirement_value_check_joint_purchase
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

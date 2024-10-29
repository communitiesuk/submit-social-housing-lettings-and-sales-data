require "rails_helper"

RSpec.describe Form::Lettings::Subsections::HouseholdCharacteristics, type: :model do
  subject(:household_characteristics) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Lettings::Sections::Household) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1)) }

  before do
    allow(section).to receive(:form).and_return(form)
  end

  it "has correct section" do
    expect(household_characteristics.section).to eq(section)
  end

  context "with start year before 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(false)
    end

    it "has correct pages" do
      expect(household_characteristics.pages.map(&:id)).to eq(
        %w[
          declaration
          household_members
          no_females_pregnant_household_lead_hhmemb_value_check
          females_in_soft_age_range_in_pregnant_household_lead_hhmemb_value_check
          lead_tenant_age
          no_females_pregnant_household_lead_age_value_check
          females_in_soft_age_range_in_pregnant_household_lead_age_value_check
          age_lead_tenant_under_retirement_value_check
          age_lead_tenant_over_retirement_value_check
          lead_tenant_gender_identity
          no_females_pregnant_household_lead_value_check
          females_in_soft_age_range_in_pregnant_household_lead_value_check
          gender_lead_tenant_over_retirement_value_check
          lead_tenant_ethnic_group
          lead_tenant_ethnic_background_arab
          lead_tenant_ethnic_background_asian
          lead_tenant_ethnic_background_black
          lead_tenant_ethnic_background_mixed
          lead_tenant_ethnic_background_white
          lead_tenant_nationality
          lead_tenant_working_situation
          working_situation_lead_tenant_under_retirement_value_check
          working_situation_lead_tenant_over_retirement_value_check
          person_2_known
          person_2_relationship_to_lead
          person_2_age
          no_females_pregnant_household_person_2_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_2_age_value_check
          age_2_under_retirement_value_check
          age_2_over_retirement_value_check
          person_2_gender_identity
          no_females_pregnant_household_person_2_value_check
          females_in_soft_age_range_in_pregnant_household_person_2_value_check
          gender_2_over_retirement_value_check
          person_2_working_situation
          working_situation_2_under_retirement_value_check
          working_situation_2_over_retirement_value_check
          person_3_known
          person_3_relationship_to_lead
          person_3_age
          no_females_pregnant_household_person_3_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_3_age_value_check
          age_3_under_retirement_value_check
          age_3_over_retirement_value_check
          person_3_gender_identity
          no_females_pregnant_household_person_3_value_check
          females_in_soft_age_range_in_pregnant_household_person_3_value_check
          gender_3_over_retirement_value_check
          person_3_working_situation
          working_situation_3_under_retirement_value_check
          working_situation_3_over_retirement_value_check
          person_4_known
          person_4_relationship_to_lead
          person_4_age
          no_females_pregnant_household_person_4_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_4_age_value_check
          age_4_under_retirement_value_check
          age_4_over_retirement_value_check
          person_4_gender_identity
          no_females_pregnant_household_person_4_value_check
          females_in_soft_age_range_in_pregnant_household_person_4_value_check
          gender_4_over_retirement_value_check
          person_4_working_situation
          working_situation_4_under_retirement_value_check
          working_situation_4_over_retirement_value_check
          person_5_known
          person_5_relationship_to_lead
          person_5_age
          no_females_pregnant_household_person_5_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_5_age_value_check
          age_5_under_retirement_value_check
          age_5_over_retirement_value_check
          person_5_gender_identity
          no_females_pregnant_household_person_5_value_check
          females_in_soft_age_range_in_pregnant_household_person_5_value_check
          gender_5_over_retirement_value_check
          person_5_working_situation
          working_situation_5_under_retirement_value_check
          working_situation_5_over_retirement_value_check
          person_6_known
          person_6_relationship_to_lead
          person_6_age
          no_females_pregnant_household_person_6_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_6_age_value_check
          age_6_under_retirement_value_check
          age_6_over_retirement_value_check
          person_6_gender_identity
          no_females_pregnant_household_person_6_value_check
          females_in_soft_age_range_in_pregnant_household_person_6_value_check
          gender_6_over_retirement_value_check
          person_6_working_situation
          working_situation_6_under_retirement_value_check
          working_situation_6_over_retirement_value_check
          person_7_known
          person_7_relationship_to_lead
          person_7_age
          no_females_pregnant_household_person_7_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_7_age_value_check
          age_7_under_retirement_value_check
          age_7_over_retirement_value_check
          person_7_gender_identity
          no_females_pregnant_household_person_7_value_check
          females_in_soft_age_range_in_pregnant_household_person_7_value_check
          gender_7_over_retirement_value_check
          person_7_working_situation
          working_situation_7_under_retirement_value_check
          working_situation_7_over_retirement_value_check
          person_8_known
          person_8_relationship_to_lead
          person_8_age
          no_females_pregnant_household_person_8_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_8_age_value_check
          age_8_under_retirement_value_check
          age_8_over_retirement_value_check
          person_8_gender_identity
          no_females_pregnant_household_person_8_value_check
          females_in_soft_age_range_in_pregnant_household_person_8_value_check
          gender_8_over_retirement_value_check
          person_8_working_situation
          working_situation_8_under_retirement_value_check
          working_situation_8_over_retirement_value_check
        ],
      )
    end
  end

  context "with start year >= 2024" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has correct pages" do
      expect(household_characteristics.pages.map(&:id)).to eq(
        %w[
          household_members
          no_females_pregnant_household_lead_hhmemb_value_check
          females_in_soft_age_range_in_pregnant_household_lead_hhmemb_value_check
          lead_tenant_age
          no_females_pregnant_household_lead_age_value_check
          females_in_soft_age_range_in_pregnant_household_lead_age_value_check
          age_lead_tenant_under_retirement_value_check
          age_lead_tenant_over_retirement_value_check
          lead_tenant_gender_identity
          no_females_pregnant_household_lead_value_check
          females_in_soft_age_range_in_pregnant_household_lead_value_check
          gender_lead_tenant_over_retirement_value_check
          lead_tenant_ethnic_group
          lead_tenant_ethnic_background_arab
          lead_tenant_ethnic_background_asian
          lead_tenant_ethnic_background_black
          lead_tenant_ethnic_background_mixed
          lead_tenant_ethnic_background_white
          lead_tenant_nationality
          lead_tenant_working_situation
          working_situation_lead_tenant_under_retirement_value_check
          working_situation_lead_tenant_over_retirement_value_check
          person_2_known
          person_2_relationship_to_lead
          relationship_2_partner_under_16_value_check
          relationship_2_multiple_partners_value_check
          person_2_age
          no_females_pregnant_household_person_2_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_2_age_value_check
          age_2_under_retirement_value_check
          age_2_over_retirement_value_check
          age_2_partner_under_16_value_check
          person_2_gender_identity
          no_females_pregnant_household_person_2_value_check
          females_in_soft_age_range_in_pregnant_household_person_2_value_check
          gender_2_over_retirement_value_check
          person_2_working_situation
          working_situation_2_under_retirement_value_check
          working_situation_2_over_retirement_value_check
          person_3_known
          person_3_relationship_to_lead
          relationship_3_partner_under_16_value_check
          relationship_3_multiple_partners_value_check
          person_3_age
          no_females_pregnant_household_person_3_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_3_age_value_check
          age_3_under_retirement_value_check
          age_3_over_retirement_value_check
          age_3_partner_under_16_value_check
          person_3_gender_identity
          no_females_pregnant_household_person_3_value_check
          females_in_soft_age_range_in_pregnant_household_person_3_value_check
          gender_3_over_retirement_value_check
          person_3_working_situation
          working_situation_3_under_retirement_value_check
          working_situation_3_over_retirement_value_check
          person_4_known
          person_4_relationship_to_lead
          relationship_4_partner_under_16_value_check
          relationship_4_multiple_partners_value_check
          person_4_age
          no_females_pregnant_household_person_4_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_4_age_value_check
          age_4_under_retirement_value_check
          age_4_over_retirement_value_check
          age_4_partner_under_16_value_check
          person_4_gender_identity
          no_females_pregnant_household_person_4_value_check
          females_in_soft_age_range_in_pregnant_household_person_4_value_check
          gender_4_over_retirement_value_check
          person_4_working_situation
          working_situation_4_under_retirement_value_check
          working_situation_4_over_retirement_value_check
          person_5_known
          person_5_relationship_to_lead
          relationship_5_partner_under_16_value_check
          relationship_5_multiple_partners_value_check
          person_5_age
          no_females_pregnant_household_person_5_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_5_age_value_check
          age_5_under_retirement_value_check
          age_5_over_retirement_value_check
          age_5_partner_under_16_value_check
          person_5_gender_identity
          no_females_pregnant_household_person_5_value_check
          females_in_soft_age_range_in_pregnant_household_person_5_value_check
          gender_5_over_retirement_value_check
          person_5_working_situation
          working_situation_5_under_retirement_value_check
          working_situation_5_over_retirement_value_check
          person_6_known
          person_6_relationship_to_lead
          relationship_6_partner_under_16_value_check
          relationship_6_multiple_partners_value_check
          person_6_age
          no_females_pregnant_household_person_6_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_6_age_value_check
          age_6_under_retirement_value_check
          age_6_over_retirement_value_check
          age_6_partner_under_16_value_check
          person_6_gender_identity
          no_females_pregnant_household_person_6_value_check
          females_in_soft_age_range_in_pregnant_household_person_6_value_check
          gender_6_over_retirement_value_check
          person_6_working_situation
          working_situation_6_under_retirement_value_check
          working_situation_6_over_retirement_value_check
          person_7_known
          person_7_relationship_to_lead
          relationship_7_partner_under_16_value_check
          relationship_7_multiple_partners_value_check
          person_7_age
          no_females_pregnant_household_person_7_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_7_age_value_check
          age_7_under_retirement_value_check
          age_7_over_retirement_value_check
          age_7_partner_under_16_value_check
          person_7_gender_identity
          no_females_pregnant_household_person_7_value_check
          females_in_soft_age_range_in_pregnant_household_person_7_value_check
          gender_7_over_retirement_value_check
          person_7_working_situation
          working_situation_7_under_retirement_value_check
          working_situation_7_over_retirement_value_check
          person_8_known
          person_8_relationship_to_lead
          relationship_8_partner_under_16_value_check
          relationship_8_multiple_partners_value_check
          person_8_age
          no_females_pregnant_household_person_8_age_value_check
          females_in_soft_age_range_in_pregnant_household_person_8_age_value_check
          age_8_under_retirement_value_check
          age_8_over_retirement_value_check
          age_8_partner_under_16_value_check
          person_8_gender_identity
          no_females_pregnant_household_person_8_value_check
          females_in_soft_age_range_in_pregnant_household_person_8_value_check
          gender_8_over_retirement_value_check
          person_8_working_situation
          working_situation_8_under_retirement_value_check
          working_situation_8_over_retirement_value_check
        ],
      )
    end
  end

  it "has the correct id" do
    expect(household_characteristics.id).to eq("household_characteristics")
  end

  it "has the correct label" do
    expect(household_characteristics.label).to eq("Household characteristics")
  end

  it "has the correct depends_on" do
    expect(household_characteristics.depends_on).to eq([
      {
        "non_location_setup_questions_completed?" => true,
      },
    ])
  end
end

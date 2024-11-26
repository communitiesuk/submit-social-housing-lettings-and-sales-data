require "rails_helper"

RSpec.describe Form::Sales::Subsections::HouseholdCharacteristics, type: :model do
  subject(:household_characteristics) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::Household) }
  let(:form) { instance_double(Form) }

  before do
    allow(section).to receive(:form).and_return(form)
  end

  it "has correct section" do
    expect(household_characteristics.section).to eq(section)
  end

  context "with 2023/24 form" do
    before do
      allow(form).to receive(:start_date).and_return(Time.zone.local(2023, 4, 1))
      allow(form).to receive(:start_year_2024_or_later?).and_return(false)
      allow(form).to receive(:start_year_2025_or_later?).and_return(false)
    end

    it "has correct pages" do
      expect(household_characteristics.pages.map(&:id)).to eq(
        %w[
          buyer_interview_joint_purchase
          buyer_interview
          privacy_notice_joint_purchase
          privacy_notice
          buyer_1_age
          age_1_retirement_value_check
          age_1_old_persons_shared_ownership_joint_purchase_value_check
          age_1_old_persons_shared_ownership_value_check
          buyer_1_gender_identity
          buyer_1_ethnic_group
          buyer_1_ethnic_background_black
          buyer_1_ethnic_background_asian
          buyer_1_ethnic_background_arab
          buyer_1_ethnic_background_mixed
          buyer_1_ethnic_background_white
          buyer_1_nationality
          buyer_1_working_situation
          working_situation_1_retirement_value_check
          working_situation_buyer_1_income_min_value_check
          buyer_1_live_in_property
          buyer_1_live_in_property_value_check
          buyer_2_relationship_to_buyer_1
          buyer_2_relationship_student_not_child_value_check
          buyer_2_age
          age_2_old_persons_shared_ownership_joint_purchase_value_check
          age_2_old_persons_shared_ownership_value_check
          age_2_buyer_retirement_value_check
          buyer_2_age_student_not_child_value_check
          buyer_2_gender_identity
          buyer_2_ethnic_group
          buyer_2_ethnic_background_black
          buyer_2_ethnic_background_asian
          buyer_2_ethnic_background_arab
          buyer_2_ethnic_background_mixed
          buyer_2_ethnic_background_white
          buyer_2_nationality
          buyer_2_working_situation
          working_situation_2_retirement_value_check_joint_purchase
          working_situation_buyer_2_income_min_value_check
          buyer_2_working_situation_student_not_child_value_check
          buyer_2_live_in_property
          buyer_2_live_in_property_value_check
          number_of_others_in_property
          number_of_others_in_property_joint_purchase
          person_2_known
          person_2_relationship_to_buyer_1
          relationship_2_student_not_child_value_check
          person_2_age
          age_2_retirement_value_check
          age_2_student_not_child_value_check
          person_2_gender_identity
          person_2_working_situation
          working_situation_2_retirement_value_check
          working_situation_2_student_not_child_value_check
          person_3_known
          person_3_relationship_to_buyer_1
          relationship_3_student_not_child_value_check
          person_3_age
          age_3_retirement_value_check
          age_3_student_not_child_value_check
          person_3_gender_identity
          person_3_working_situation
          working_situation_3_retirement_value_check
          working_situation_3_student_not_child_value_check
          person_4_known
          person_4_relationship_to_buyer_1
          relationship_4_student_not_child_value_check
          person_4_age
          age_4_retirement_value_check
          age_4_student_not_child_value_check
          person_4_gender_identity
          person_4_working_situation
          working_situation_4_retirement_value_check
          working_situation_4_student_not_child_value_check
          person_5_known
          person_5_relationship_to_buyer_1
          relationship_5_student_not_child_value_check
          person_5_age
          age_5_retirement_value_check
          age_5_student_not_child_value_check
          person_5_gender_identity
          person_5_working_situation
          working_situation_5_retirement_value_check
          working_situation_5_student_not_child_value_check
          person_6_known
          person_6_relationship_to_buyer_1
          relationship_6_student_not_child_value_check
          person_6_age
          age_6_retirement_value_check
          age_6_student_not_child_value_check
          person_6_gender_identity
          person_6_working_situation
          working_situation_6_retirement_value_check
          working_situation_6_student_not_child_value_check
        ],
      )
    end
  end

  context "with 2024/25 form" do
    before do
      allow(form).to receive(:start_date).and_return(Time.zone.local(2024, 4, 1))
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
      allow(form).to receive(:start_year_2025_or_later?).and_return(false)
    end

    it "has correct depends on" do
      expect(household_characteristics.depends_on).to eq([{ "setup_completed?" => true, "company_buyer?" => false }])
    end

    context "when the sale is to a company buyer" do
      let(:log) { FactoryBot.build(:sales_log, ownershipsch: 3, companybuy: 1) }

      it "is not displayed in tasklist" do
        expect(household_characteristics.displayed_in_tasklist?(log)).to eq(false)
      end
    end

    context "when the sale is not to a company buyer" do
      let(:log) { FactoryBot.build(:sales_log, ownershipsch: 3, companybuy: 2) }

      it "is displayed in tasklist" do
        expect(household_characteristics.displayed_in_tasklist?(log)).to eq(true)
      end
    end

    it "has correct pages" do
      expect(household_characteristics.pages.map(&:id)).to eq(
        %w[
          buyer_1_age
          age_1_retirement_value_check
          age_1_not_retired_value_check
          age_1_old_persons_shared_ownership_joint_purchase_value_check
          age_1_old_persons_shared_ownership_value_check
          buyer_1_gender_identity
          buyer_1_ethnic_group
          buyer_1_ethnic_background_black
          buyer_1_ethnic_background_asian
          buyer_1_ethnic_background_arab
          buyer_1_ethnic_background_mixed
          buyer_1_ethnic_background_white
          buyer_1_nationality
          buyer_1_working_situation
          working_situation_1_retirement_value_check
          working_situation_1_not_retired_value_check
          working_situation_buyer_1_income_min_value_check
          buyer_1_live_in_property
          buyer_1_live_in_property_value_check
          buyer_2_relationship_to_buyer_1
          buyer_2_relationship_student_not_child_value_check
          buyer_2_age
          age_2_old_persons_shared_ownership_joint_purchase_value_check
          age_2_old_persons_shared_ownership_value_check
          age_2_buyer_retirement_value_check
          age_2_buyer_not_retired_value_check
          buyer_2_age_student_not_child_value_check
          buyer_2_gender_identity
          buyer_2_ethnic_group
          buyer_2_ethnic_background_black
          buyer_2_ethnic_background_asian
          buyer_2_ethnic_background_arab
          buyer_2_ethnic_background_mixed
          buyer_2_ethnic_background_white
          buyer_2_nationality
          buyer_2_working_situation
          working_situation_2_retirement_value_check_joint_purchase
          working_situation_2_not_retired_value_check_joint_purchase
          working_situation_buyer_2_income_min_value_check
          buyer_2_working_situation_student_not_child_value_check
          buyer_2_live_in_property
          buyer_2_live_in_property_value_check
          number_of_others_in_property
          number_of_others_in_property_joint_purchase
          person_2_known
          person_2_relationship_to_buyer_1
          relationship_2_partner_under_16_value_check
          relationship_2_multiple_partners_value_check
          relationship_2_student_not_child_value_check
          person_2_age
          age_2_retirement_value_check
          age_2_not_retired_value_check
          age_2_student_not_child_value_check
          age_2_partner_under_16_value_check
          person_2_gender_identity
          person_2_working_situation
          working_situation_2_retirement_value_check
          working_situation_2_not_retired_value_check
          working_situation_2_student_not_child_value_check
          person_3_known
          person_3_relationship_to_buyer_1
          relationship_3_partner_under_16_value_check
          relationship_3_multiple_partners_value_check
          relationship_3_student_not_child_value_check
          person_3_age
          age_3_retirement_value_check
          age_3_not_retired_value_check
          age_3_student_not_child_value_check
          age_3_partner_under_16_value_check
          person_3_gender_identity
          person_3_working_situation
          working_situation_3_retirement_value_check
          working_situation_3_not_retired_value_check
          working_situation_3_student_not_child_value_check
          person_4_known
          person_4_relationship_to_buyer_1
          relationship_4_partner_under_16_value_check
          relationship_4_multiple_partners_value_check
          relationship_4_student_not_child_value_check
          person_4_age
          age_4_retirement_value_check
          age_4_not_retired_value_check
          age_4_student_not_child_value_check
          age_4_partner_under_16_value_check
          person_4_gender_identity
          person_4_working_situation
          working_situation_4_retirement_value_check
          working_situation_4_not_retired_value_check
          working_situation_4_student_not_child_value_check
          person_5_known
          person_5_relationship_to_buyer_1
          relationship_5_partner_under_16_value_check
          relationship_5_multiple_partners_value_check
          relationship_5_student_not_child_value_check
          person_5_age
          age_5_retirement_value_check
          age_5_not_retired_value_check
          age_5_student_not_child_value_check
          age_5_partner_under_16_value_check
          person_5_gender_identity
          person_5_working_situation
          working_situation_5_retirement_value_check
          working_situation_5_not_retired_value_check
          working_situation_5_student_not_child_value_check
          person_6_known
          person_6_relationship_to_buyer_1
          relationship_6_partner_under_16_value_check
          relationship_6_multiple_partners_value_check
          relationship_6_student_not_child_value_check
          person_6_age
          age_6_retirement_value_check
          age_6_not_retired_value_check
          age_6_student_not_child_value_check
          age_6_partner_under_16_value_check
          person_6_gender_identity
          person_6_working_situation
          working_situation_6_retirement_value_check
          working_situation_6_not_retired_value_check
          working_situation_6_student_not_child_value_check
        ],
      )
    end
  end

  context "with 2025/26 form" do
    before do
      allow(form).to receive(:start_date).and_return(Time.zone.local(2025, 4, 1))
      allow(form).to receive(:start_year_2024_or_later?).and_return(true)
      allow(form).to receive(:start_year_2025_or_later?).and_return(true)
    end

    it "has correct pages" do
      expect(household_characteristics.pages.map(&:id)).to eq(
        %w[
          buyer_1_age
          age_1_retirement_value_check
          age_1_not_retired_value_check
          age_1_old_persons_shared_ownership_joint_purchase_value_check
          age_1_old_persons_shared_ownership_value_check
          buyer_1_gender_identity
          buyer_1_ethnic_group
          buyer_1_ethnic_background_black
          buyer_1_ethnic_background_asian
          buyer_1_ethnic_background_arab
          buyer_1_ethnic_background_mixed
          buyer_1_ethnic_background_white
          buyer_1_nationality
          buyer_1_working_situation
          working_situation_1_retirement_value_check
          working_situation_1_not_retired_value_check
          working_situation_buyer_1_income_min_value_check
          working_situation_buyer_1_income_max_value_check
          buyer_1_live_in_property
          buyer_1_live_in_property_value_check
          buyer_2_relationship_to_buyer_1
          buyer_2_relationship_student_not_child_value_check
          buyer_2_age
          age_2_old_persons_shared_ownership_joint_purchase_value_check
          age_2_old_persons_shared_ownership_value_check
          age_2_buyer_retirement_value_check
          age_2_buyer_not_retired_value_check
          buyer_2_age_student_not_child_value_check
          buyer_2_gender_identity
          buyer_2_ethnic_group
          buyer_2_ethnic_background_black
          buyer_2_ethnic_background_asian
          buyer_2_ethnic_background_arab
          buyer_2_ethnic_background_mixed
          buyer_2_ethnic_background_white
          buyer_2_nationality
          buyer_2_working_situation
          working_situation_2_retirement_value_check_joint_purchase
          working_situation_2_not_retired_value_check_joint_purchase
          working_situation_buyer_2_income_min_value_check
          working_situation_buyer_2_income_max_value_check
          buyer_2_working_situation_student_not_child_value_check
          buyer_2_live_in_property
          buyer_2_live_in_property_value_check
          number_of_others_in_property
          number_of_others_in_property_joint_purchase
          person_2_known
          person_2_relationship_to_buyer_1
          relationship_2_partner_under_16_value_check
          relationship_2_multiple_partners_value_check
          relationship_2_student_not_child_value_check
          person_2_age
          age_2_retirement_value_check
          age_2_not_retired_value_check
          age_2_student_not_child_value_check
          age_2_partner_under_16_value_check
          person_2_gender_identity
          person_2_working_situation
          working_situation_2_retirement_value_check
          working_situation_2_not_retired_value_check
          working_situation_2_student_not_child_value_check
          person_3_known
          person_3_relationship_to_buyer_1
          relationship_3_partner_under_16_value_check
          relationship_3_multiple_partners_value_check
          relationship_3_student_not_child_value_check
          person_3_age
          age_3_retirement_value_check
          age_3_not_retired_value_check
          age_3_student_not_child_value_check
          age_3_partner_under_16_value_check
          person_3_gender_identity
          person_3_working_situation
          working_situation_3_retirement_value_check
          working_situation_3_not_retired_value_check
          working_situation_3_student_not_child_value_check
          person_4_known
          person_4_relationship_to_buyer_1
          relationship_4_partner_under_16_value_check
          relationship_4_multiple_partners_value_check
          relationship_4_student_not_child_value_check
          person_4_age
          age_4_retirement_value_check
          age_4_not_retired_value_check
          age_4_student_not_child_value_check
          age_4_partner_under_16_value_check
          person_4_gender_identity
          person_4_working_situation
          working_situation_4_retirement_value_check
          working_situation_4_not_retired_value_check
          working_situation_4_student_not_child_value_check
          person_5_known
          person_5_relationship_to_buyer_1
          relationship_5_partner_under_16_value_check
          relationship_5_multiple_partners_value_check
          relationship_5_student_not_child_value_check
          person_5_age
          age_5_retirement_value_check
          age_5_not_retired_value_check
          age_5_student_not_child_value_check
          age_5_partner_under_16_value_check
          person_5_gender_identity
          person_5_working_situation
          working_situation_5_retirement_value_check
          working_situation_5_not_retired_value_check
          working_situation_5_student_not_child_value_check
          person_6_known
          person_6_relationship_to_buyer_1
          relationship_6_partner_under_16_value_check
          relationship_6_multiple_partners_value_check
          relationship_6_student_not_child_value_check
          person_6_age
          age_6_retirement_value_check
          age_6_not_retired_value_check
          age_6_student_not_child_value_check
          age_6_partner_under_16_value_check
          person_6_gender_identity
          person_6_working_situation
          working_situation_6_retirement_value_check
          working_situation_6_not_retired_value_check
          working_situation_6_student_not_child_value_check
        ],
      )
    end

    it "has correct depends on" do
      expect(household_characteristics.depends_on).to eq([{ "setup_completed?" => true }])
    end
  end
end

require "rails_helper"

RSpec.describe Form::Sales::Subsections::IncomeBenefitsAndSavings, type: :model do
  subject(:subsection) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::Household, form:) }
  let(:form) { instance_double(Form, start_date: Time.utc(2024, 4, 1), start_year_2025_or_later?: false) }

  it "has correct section" do
    expect(subsection.section).to eq(section)
  end

  it "has the correct id" do
    expect(subsection.id).to eq("income_benefits_and_savings")
  end

  it "has the correct label" do
    expect(subsection.label).to eq("Income, benefits and savings")
  end

  context "when before 2025" do
    let(:form) { instance_double(Form, start_date: Time.utc(2024, 4, 1), start_year_2025_or_later?: false) }

    it "has correct pages" do
      expect(subsection.pages.map(&:id)).to eq(
        %w[
          buyer_1_income
          buyer_1_income_ecstat_value_check
          buyer_1_income_discounted_max_value_check
          buyer_1_combined_income_max_value_check
          buyer_1_income_mortgage_value_check
          buyer_1_mortgage
          buyer_1_mortgage_value_check
          buyer_2_income
          buyer_2_income_mortgage_value_check
          buyer_2_income_ecstat_value_check
          buyer_2_income_discounted_max_value_check
          buyer_2_combined_income_max_value_check
          buyer_2_mortgage
          buyer_2_mortgage_value_check
          housing_benefits_joint_purchase
          housing_benefits_not_joint_purchase
          savings_joint_purchase
          savings
          savings_joint_purchase_value_check
          savings_value_check
          savings_deposit_joint_purchase_value_check
          savings_deposit_value_check
          previous_ownership_joint_purchase
          previous_ownership_not_joint_purchase
          previous_shared
        ],
      )
    end

    it "has correct depends on" do
      expect(subsection.depends_on).to eq([{ "setup_completed?" => true }])
    end
  end

  context "when 2025" do
    let(:form) { instance_double(Form, start_date: Time.utc(2025, 4, 1), start_year_2025_or_later?: true) }

    it "has correct pages" do
      expect(subsection.pages.map(&:id)).to eq(
        %w[
          buyer_1_income
          buyer_1_income_ecstat_value_check
          buyer_1_income_discounted_max_value_check
          buyer_1_combined_income_max_value_check
          buyer_1_income_mortgage_value_check
          buyer_1_mortgage
          buyer_1_mortgage_value_check
          buyer_2_income
          buyer_2_income_mortgage_value_check
          buyer_2_income_ecstat_value_check
          buyer_2_income_discounted_max_value_check
          buyer_2_combined_income_max_value_check
          buyer_2_mortgage
          buyer_2_mortgage_value_check
          housing_benefits_joint_purchase
          housing_benefits_not_joint_purchase
          savings_joint_purchase
          savings
          savings_joint_purchase_value_check
          savings_value_check
          savings_deposit_joint_purchase_value_check
          savings_deposit_value_check
          previous_ownership_joint_purchase
          previous_ownership_not_joint_purchase
          previous_shared
        ],
      )
    end

    it "has correct depends on" do
      expect(subsection.depends_on).to eq([{ "setup_completed?" => true, "is_staircase?" => false }])
    end
  end
end

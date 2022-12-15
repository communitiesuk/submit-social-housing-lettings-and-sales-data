require "rails_helper"

RSpec.describe Form::Sales::Subsections::IncomeBenefitsAndSavings, type: :model do
  subject(:subsection) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::Household) }

  it "has correct section" do
    expect(subsection.section).to eq(section)
  end

  it "has correct pages" do
    expect(subsection.pages.map(&:id)).to eq(
      %w[
        buyer_1_income
        buyer_1_income_value_check
        buyer_1_income_mortgage_value_check
        buyer_1_mortgage
        buyer_1_mortgage_value_check
        buyer_2_income
        buyer_2_income_mortgage_value_check
        buyer_2_mortgage
        buyer_2_mortgage_value_check
        housing_benefits
        savings
        savings_value_check
        savings_deposit_value_check
        previous_ownership
      ],
    )
  end

  it "has the correct id" do
    expect(subsection.id).to eq("income_benefits_and_savings")
  end

  it "has the correct label" do
    expect(subsection.label).to eq("Income, benefits and savings")
  end

  it "has correct depends on" do
    expect(subsection.depends_on).to eq([{ "setup_completed?" => true }])
  end
end

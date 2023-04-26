require "rails_helper"

RSpec.describe Form::Lettings::Subsections::IncomeAndBenefits, type: :model do
  subject(:income_and_benefits) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Lettings::Sections::RentAndCharges) }

  it "has correct section" do
    expect(income_and_benefits.section).to eq(section)
  end

  it "has correct pages" do
    expect(income_and_benefits.pages.map(&:id)).to eq(
      %w[
        income_known
        income_amount
        net_income_value_check
        housing_benefit
        benefits_proportion
        rent_or_other_charges
        rent_period
        care_home_weekly
        care_home_bi_weekly
        care_home_4_weekly
        care_home_monthly
        care_home_charges_value_check
        rent_weekly
        rent_bi_weekly
        rent_4_weekly
        rent_monthly
        brent_min_rent_value_check
        brent_max_rent_value_check
        outstanding
        outstanding_amount
      ],
    )
  end

  it "has the correct id" do
    expect(income_and_benefits.id).to eq("income_and_benefits")
  end

  it "has the correct label" do
    expect(income_and_benefits.label).to eq("Income, benefits and outgoings")
  end

  it "has the correct depends_on" do
    expect(income_and_benefits.depends_on).to eq([
      {
        "non_location_setup_questions_completed?" => true,
      },
    ])
  end
end

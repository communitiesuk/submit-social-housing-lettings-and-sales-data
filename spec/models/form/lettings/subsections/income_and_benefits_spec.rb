require "rails_helper"

RSpec.describe Form::Lettings::Subsections::IncomeAndBenefits, type: :model do
  subject(:income_and_benefits) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:start_date) { Time.zone.local(2024, 4, 1) }
  let(:start_year_2025_or_later) { false }
  let(:form) { instance_double(Form, start_date:) }
  let(:section) { instance_double(Form::Lettings::Sections::RentAndCharges, form:) }

  before do
    allow(form).to receive(:start_year_2025_or_later?).and_return(start_year_2025_or_later)
  end

  it "has correct section" do
    expect(income_and_benefits.section).to eq(section)
  end

  context "with 2024 form" do
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
          brent_rent_value_check
          scharge_value_check
          pscharge_value_check
          supcharg_value_check
          outstanding
          outstanding_amount
        ],
      )
    end
  end

  context "with 2025 form" do
    let(:start_date) { Time.zone.local(2025, 4, 1) }
    let(:start_year_2025_or_later) { true }

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
          rent_weekly
          rent_bi_weekly
          rent_4_weekly
          rent_monthly
          brent_rent_value_check
          scharge_value_check
          pscharge_value_check
          supcharg_value_check
          outstanding
          outstanding_amount
        ],
      )
    end
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

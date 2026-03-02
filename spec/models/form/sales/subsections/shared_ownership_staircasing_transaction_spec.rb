require "rails_helper"

RSpec.describe Form::Sales::Subsections::SharedOwnershipStaircasingTransaction, type: :model do
  subject(:shared_ownership_staircasing_transaction) { described_class.new(nil, nil, section) }

  let(:form) { instance_double(Form, start_year_2026_or_later?: false) }
  let(:section) { instance_double(Form::Sales::Sections::SaleInformation, form:) }

  it "has correct section" do
    expect(shared_ownership_staircasing_transaction.section).to eq(section)
  end

  it "has the correct depends_on" do
    expect(shared_ownership_staircasing_transaction.depends_on).to eq([{ "ownershipsch" => 1, "setup_completed?" => true, "staircase" => 1 }])
  end

  it "has the correct id" do
    expect(shared_ownership_staircasing_transaction.id).to eq("shared_ownership_staircasing_transaction")
  end

  it "has the correct label" do
    expect(shared_ownership_staircasing_transaction.label).to eq("Shared ownership - staircasing transaction")
  end

  it "has the correct copy key" do
    expect(shared_ownership_staircasing_transaction.copy_key).to eq("sale_information")
  end

  context "when the start year is 2025" do
    let(:form) { instance_double(Form, start_year_2025_or_later?: true, start_year_2026_or_later?: false, start_date: Time.utc(2025, 4, 1)) }

    it "has correct pages" do
      expect(shared_ownership_staircasing_transaction.pages.map(&:id)).to eq(
        %w[
          about_staircasing_joint_purchase
          about_staircasing_not_joint_purchase
          staircase_sale
          staircase_bought_value_check
          staircase_owned_value_check_joint_purchase
          staircase_owned_value_check_not_joint_purchase
          staircase_first_time
          staircase_previous
          staircase_initial_date
          value_shared_ownership_staircase
          about_price_shared_ownership_value_check_staircasing
          staircase_equity
          shared_ownership_equity_value_check_staircasing
          staircase_mortgage_used_shared_ownership
          monthly_rent_staircasing_owned
          monthly_rent_staircasing
          monthly_charges_shared_ownership_value_check
        ],
      )
    end
  end

  context "when the start year is 2026" do
    let(:form) { instance_double(Form, start_year_2025_or_later?: true, start_year_2026_or_later?: true, start_date: Time.utc(2026, 4, 1)) }

    it "has correct pages" do
      expect(shared_ownership_staircasing_transaction.pages.map(&:id)).to eq(
        %w[
          about_staircasing_joint_purchase
          about_staircasing_not_joint_purchase
          staircase_sale
          staircase_bought_value_check
          staircase_owned_value_check_joint_purchase
          staircase_owned_value_check_not_joint_purchase
          staircase_first_time
          staircase_previous
          staircase_initial_date
          value_shared_ownership_staircase
          about_price_shared_ownership_value_check_staircasing
          staircase_equity
          shared_ownership_equity_value_check_staircasing
          staircase_mortgage_used_shared_ownership
          monthly_rent_staircasing_owned
          monthly_rent_staircasing
          service_charge_staircasing
          monthly_charges_shared_ownership_value_check
        ],
      )
    end
  end
end

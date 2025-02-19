require "rails_helper"

RSpec.describe Form::Sales::Subsections::DiscountedOwnershipScheme, type: :model do
  subject(:discounted_ownership_scheme) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_2025_or_later?: false) }
  let(:section) { instance_double(Form::Sales::Sections::SaleInformation, form:) }

  it "has correct section" do
    expect(discounted_ownership_scheme.section).to eq(section)
  end

  it "has correct pages" do
    expect(discounted_ownership_scheme.pages.map(&:id)).to eq(
      %w[
        living_before_purchase_discounted_ownership_joint_purchase
        living_before_purchase_discounted_ownership
        purchase_price
        discount
        extra_borrowing_price_value_check
        percentage_discount_value_check
        grant
        grant_value_check
        purchase_price_discounted_ownership
        discounted_sale_grant_value_check
        about_price_discounted_ownership_value_check
        discounted_ownership_deposit_and_mortgage_value_check_after_value_and_discount
        mortgage_used_discounted_ownership
        discounted_ownership_mortgage_used_mortgage_value_check
        discounted_sale_mortgage_used_value_check
        mortgage_amount_discounted_ownership
        discounted_ownership_mortgage_amount_mortgage_value_check
        discounted_sale_mortgage_value_check
        extra_borrowing_mortgage_value_check
        discounted_ownership_deposit_and_mortgage_value_check_after_mortgage
        mortgage_lender_discounted_ownership
        mortgage_lender_other_discounted_ownership
        mortgage_length_discounted_ownership
        extra_borrowing_discounted_ownership
        extra_borrowing_value_check
        deposit_discounted_ownership
        extra_borrowing_deposit_value_check
        discounted_ownership_deposit_joint_purchase_value_check
        discounted_ownership_deposit_value_check
        discounted_ownership_deposit_and_mortgage_value_check_after_deposit
        discounted_sale_deposit_value_check
        leasehold_charges_discounted_ownership
        monthly_charges_discounted_ownership_value_check
      ],
    )
  end

  it "has the correct id" do
    expect(discounted_ownership_scheme.id).to eq("discounted_ownership_scheme")
  end

  it "has the correct copy key" do
    expect(discounted_ownership_scheme.copy_key).to eq("sale_information")
  end

  it "has the correct label" do
    expect(discounted_ownership_scheme.label).to eq("Discounted ownership scheme")
  end

  it "has the correct depends_on" do
    expect(discounted_ownership_scheme.depends_on).to eq([
      {
        "ownershipsch" => 2, "setup_completed?" => true
      },
    ])
  end

  context "when it is a discounted ownership scheme" do
    let(:log) { FactoryBot.build(:sales_log, ownershipsch: 2) }

    it "is displayed in tasklist" do
      expect(discounted_ownership_scheme.displayed_in_tasklist?(log)).to eq(true)
    end
  end

  context "when it is not a discounted ownership scheme" do
    let(:log) { FactoryBot.build(:sales_log, ownershipsch: 1) }

    it "is displayed in tasklist" do
      expect(discounted_ownership_scheme.displayed_in_tasklist?(log)).to eq(false)
    end
  end

  context "with form on or after 2025" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2025, 4, 1), start_year_2025_or_later?: true) }

    it "has correct pages" do
      expect(discounted_ownership_scheme.pages.map(&:id)).to eq(
        %w[
          living_before_purchase_discounted_ownership_joint_purchase
          living_before_purchase_discounted_ownership
          purchase_price
          discount
          extra_borrowing_price_value_check
          percentage_discount_value_check
          grant
          grant_value_check
          purchase_price_discounted_ownership
          discounted_sale_grant_value_check
          about_price_discounted_ownership_value_check
          discounted_ownership_deposit_and_mortgage_value_check_after_value_and_discount
          mortgage_used_discounted_ownership
          discounted_ownership_mortgage_used_mortgage_value_check
          discounted_sale_mortgage_used_value_check
          mortgage_amount_discounted_ownership
          discounted_ownership_mortgage_amount_mortgage_value_check
          discounted_sale_mortgage_value_check
          extra_borrowing_mortgage_value_check
          discounted_ownership_deposit_and_mortgage_value_check_after_mortgage
          mortgage_length_discounted_ownership
          extra_borrowing_discounted_ownership
          extra_borrowing_value_check
          deposit_discounted_ownership
          extra_borrowing_deposit_value_check
          discounted_ownership_deposit_joint_purchase_value_check
          discounted_ownership_deposit_value_check
          discounted_ownership_deposit_and_mortgage_value_check_after_deposit
          discounted_sale_deposit_value_check
          leasehold_charges_discounted_ownership
          monthly_charges_discounted_ownership_value_check
        ],
      )
    end
  end
end

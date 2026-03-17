require "rails_helper"

RSpec.describe Form::Sales::Subsections::SharedOwnershipInitialPurchase, type: :model do
  include CollectionTimeHelper

  subject(:shared_ownership_initial_purchase) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:start_year_2024_or_later?) { true }
  let(:start_year_2025_or_later?) { true }
  let(:start_year_2026_or_later?) { true }
  let(:start_date) { current_collection_start_date }
  let(:form) { instance_double(Form, start_date:, start_year_2024_or_later?: start_year_2024_or_later?, start_year_2025_or_later?: start_year_2025_or_later?, start_year_2026_or_later?: start_year_2026_or_later?) }
  let(:section) { instance_double(Form::Sales::Sections::SaleInformation) }

  before do
    allow(section).to receive(:form).and_return(form)
  end

  it "has correct section" do
    expect(shared_ownership_initial_purchase.section).to eq(section)
  end

  context "when 2024", metadata: { year: 24 } do
    let(:start_year_2025_or_later?) { false }
    let(:start_year_2026_or_later?) { false }
    let(:start_date) { collection_start_date_for_year(2024) }

    it "has correct pages" do
      expect(shared_ownership_initial_purchase.pages.map(&:id)).to eq(
        %w[
          resale
          living_before_purchase_shared_ownership_joint_purchase
          living_before_purchase_shared_ownership
          handover_date
          handover_date_check
          buyer_previous_joint_purchase
          buyer_previous_not_joint_purchase
          previous_bedrooms
          previous_property_type
          shared_ownership_previous_tenure
          value_shared_ownership
          about_price_shared_ownership_value_check
          initial_equity
          shared_ownership_equity_value_check
          mortgage_used_shared_ownership
          mortgage_used_mortgage_value_check
          mortgage_amount_shared_ownership
          shared_ownership_mortgage_amount_value_check
          mortgage_amount_mortgage_value_check
          mortgage_length_shared_ownership
          deposit_shared_ownership
          deposit_shared_ownership_optional
          deposit_joint_purchase_value_check
          deposit_value_check
          deposit_discount
          deposit_discount_optional
          shared_ownership_deposit_value_check
          monthly_rent
          service_charge
          monthly_charges_shared_ownership_value_check
          estate_management_fee
        ],
      )
    end
  end

  context "when 2025", metadata: { year: 25 } do
    let(:start_year_2026_or_later?) { false }
    let(:start_date) { collection_start_date_for_year(2025) }

    it "has correct pages" do
      expect(shared_ownership_initial_purchase.pages.map(&:id)).to eq(
        %w[
          resale
          living_before_purchase_shared_ownership_joint_purchase
          living_before_purchase_shared_ownership
          handover_date
          handover_date_check
          buyer_previous_joint_purchase
          buyer_previous_not_joint_purchase
          previous_bedrooms
          previous_property_type
          shared_ownership_previous_tenure
          value_shared_ownership
          about_price_shared_ownership_value_check
          initial_equity
          shared_ownership_equity_value_check
          mortgage_used_shared_ownership
          mortgage_used_mortgage_value_check
          mortgage_amount_shared_ownership
          shared_ownership_mortgage_amount_value_check
          mortgage_amount_mortgage_value_check
          mortgage_length_shared_ownership
          deposit_shared_ownership
          deposit_shared_ownership_optional
          deposit_joint_purchase_value_check
          deposit_value_check
          deposit_discount
          deposit_discount_optional
          shared_ownership_deposit_value_check
          monthly_rent
          service_charge
          monthly_charges_shared_ownership_value_check
          estate_management_fee
        ],
      )
    end
  end

  context "when 2026", metadata: { year: 26 } do
    let(:start_date) { collection_start_date_for_year(2026) }

    it "has correct pages" do
      expect(shared_ownership_initial_purchase.pages.map(&:id)).to eq(
        %w[
          resale
          living_before_purchase_shared_ownership_joint_purchase
          living_before_purchase_shared_ownership
          handover_date
          handover_date_check
          buyer_previous_joint_purchase
          buyer_previous_not_joint_purchase
          previous_bedrooms
          previous_property_type
          shared_ownership_previous_tenure
          value_shared_ownership
          about_price_shared_ownership_value_check
          initial_equity
          shared_ownership_equity_value_check
          mortgage_used_shared_ownership
          mortgage_used_mortgage_value_check
          mortgage_amount_shared_ownership
          shared_ownership_mortgage_amount_value_check
          mortgage_amount_mortgage_value_check
          mortgage_length_shared_ownership_not_interviewed
          mortgage_length_shared_ownership_interviewed
          deposit_shared_ownership
          deposit_shared_ownership_optional
          deposit_joint_purchase_value_check
          deposit_value_check
          deposit_discount
          deposit_discount_optional
          shared_ownership_deposit_value_check
          monthly_rent
          service_charge
          monthly_charges_shared_ownership_value_check
          estate_management_fee
        ],
      )
    end
  end

  it "has the correct id" do
    expect(shared_ownership_initial_purchase.id).to eq("shared_ownership_initial_purchase")
  end

  it "has the correct label" do
    expect(shared_ownership_initial_purchase.label).to eq("Shared ownership - initial purchase")
  end

  it "has the correct depends_on" do
    expect(shared_ownership_initial_purchase.depends_on).to eq([
      {
        "ownershipsch" => 1, "setup_completed?" => true, "staircase" => 2
      },
    ])
  end

  context "when it is a shared ownership scheme and not staircase" do
    let(:log) { FactoryBot.build(:sales_log, ownershipsch: 1, staircase: 2) }

    it "is displayed in tasklist" do
      expect(shared_ownership_initial_purchase.displayed_in_tasklist?(log)).to be(true)
    end
  end

  context "when it is not a shared ownership scheme" do
    let(:log) { FactoryBot.build(:sales_log, ownershipsch: 2, staircase: 2) }

    it "is displayed in tasklist" do
      expect(shared_ownership_initial_purchase.displayed_in_tasklist?(log)).to be(false)
    end
  end

  context "when it is staircase" do
    let(:log) { FactoryBot.build(:sales_log, ownershipsch: 1, staircase: 1) }

    it "is displayed in tasklist" do
      expect(shared_ownership_initial_purchase.displayed_in_tasklist?(log)).to be(false)
    end
  end
end

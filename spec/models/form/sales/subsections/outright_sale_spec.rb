require "rails_helper"

RSpec.describe Form::Sales::Subsections::OutrightSale, type: :model do
  include CollectionTimeHelper

  subject(:outright_sale) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:start_year_2024_or_later?) { true }
  let(:start_year_2025_or_later?) { true }
  let(:start_year_2026_or_later?) { true }
  let(:start_date) { current_collection_start_date }
  let(:section) { instance_double(Form::Sales::Sections::SaleInformation) }
  let(:form) { instance_double(Form, start_date:, start_year_2024_or_later?: start_year_2024_or_later?, start_year_2025_or_later?: start_year_2025_or_later?, start_year_2026_or_later?: start_year_2026_or_later?) }

  before do
    allow(section).to receive(:form).and_return(form)
  end

  it "has correct section" do
    expect(outright_sale.section).to eq(section)
  end

  describe "pages" do
    let(:section) { instance_double(described_class, form: instance_double(Form)) }

    context "when 2024", metadata: { year: 24 } do
      let(:start_year_2025_or_later?) { false }
      let(:start_year_2026_or_later?) { false }
      let(:start_date) { collection_start_date_for_year(2024) }

      it "has correct pages" do
        expect(outright_sale.pages.map(&:id)).to eq(
          %w[
            purchase_price_outright_sale
            about_price_outright_sale_value_check
            mortgage_used_outright_sale
            outright_sale_mortgage_used_mortgage_value_check
            mortgage_amount_outright_sale
            outright_sale_mortgage_amount_mortgage_value_check
            mortgage_length_outright_sale
            extra_borrowing_outright_sale
            deposit_outright_sale
            outright_sale_deposit_joint_purchase_value_check
            outright_sale_deposit_value_check
            leasehold_charges_outright_sale
            monthly_charges_outright_sale_value_check
          ],
        )
      end
    end

    context "when 2025", metadata: { year: 25 } do
      let(:start_year_2026_or_later?) { false }
      let(:start_date) { collection_start_date_for_year(2025) }

      it "has correct pages" do
        expect(outright_sale.pages.map(&:id)).to eq(
          %w[
            purchase_price_outright_sale
            about_price_outright_sale_value_check
            mortgage_used_outright_sale
            outright_sale_mortgage_used_mortgage_value_check
            mortgage_amount_outright_sale
            outright_sale_mortgage_amount_mortgage_value_check
            mortgage_length_outright_sale
            extra_borrowing_outright_sale
            deposit_outright_sale
            outright_sale_deposit_joint_purchase_value_check
            outright_sale_deposit_value_check
            leasehold_charges_outright_sale
            monthly_charges_outright_sale_value_check
          ],
        )
      end
    end

    context "when 2026", metadata: { year: 26 } do
      let(:start_date) { collection_start_date_for_year(2026) }

      it "has correct pages" do
        expect(outright_sale.pages.map(&:id)).to eq(
          %w[
            purchase_price_outright_sale
            about_price_outright_sale_value_check
            mortgage_used_outright_sale
            outright_sale_mortgage_used_mortgage_value_check
            mortgage_amount_outright_sale
            outright_sale_mortgage_amount_mortgage_value_check
            mortgage_length_outright_sale_not_interviewed
            mortgage_length_outright_sale_interviewed
            extra_borrowing_outright_sale
            deposit_outright_sale
            outright_sale_deposit_joint_purchase_value_check
            outright_sale_deposit_value_check
            leasehold_charges_outright_sale
            monthly_charges_outright_sale_value_check
          ],
        )
      end
    end
  end

  it "has the correct id" do
    expect(outright_sale.id).to eq("outright_sale")
  end

  it "has the correct copy key" do
    expect(outright_sale.copy_key).to eq("sale_information")
  end

  it "has the correct label" do
    expect(outright_sale.label).to eq("Outright sale")
  end

  it "has the correct depends_on" do
    expect(outright_sale.depends_on).to eq([
      {
        "ownershipsch" => 3, "setup_completed?" => true
      },
    ])
  end

  context "when it is a outright sale" do
    let(:log) { FactoryBot.build(:sales_log, ownershipsch: 3) }

    it "is displayed in tasklist" do
      expect(outright_sale.displayed_in_tasklist?(log)).to be(true)
    end
  end

  context "when it is not a outright sale" do
    let(:log) { FactoryBot.build(:sales_log, ownershipsch: 2) }

    it "is displayed in tasklist" do
      expect(outright_sale.displayed_in_tasklist?(log)).to be(false)
    end
  end
end

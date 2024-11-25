require "rails_helper"

RSpec.describe Form::Sales::Subsections::OutrightSale, type: :model do
  subject(:outright_sale) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::SaleInformation) }
  let(:form) { instance_double(Form) }

  before do
    allow(section).to receive(:form).and_return(form)
  end

  it "has correct section" do
    expect(outright_sale.section).to eq(section)
  end

  describe "pages" do
    let(:section) { instance_double(described_class, form: instance_double(Form)) }

    context "when 2022" do
      before do
        allow(form).to receive(:start_date).and_return(Time.zone.local(2022, 2, 8))
        allow(form).to receive(:start_year_2024_or_later?).and_return(false)
      end

      it "has correct pages" do
        expect(outright_sale.pages.compact.map(&:id)).to eq(
          %w[
            purchase_price_outright_sale
            about_price_outright_sale_value_check
            mortgage_used_outright_sale
            outright_sale_mortgage_used_mortgage_value_check
            mortgage_amount_outright_sale
            outright_sale_mortgage_amount_mortgage_value_check
            mortgage_lender_outright_sale
            mortgage_lender_other_outright_sale
            mortgage_length_outright_sale
            extra_borrowing_outright_sale
            deposit_outright_sale
            outright_sale_deposit_joint_purchase_value_check
            outright_sale_deposit_value_check
            monthly_charges_outright_sale_value_check
          ],
        )
      end
    end

    context "when 2023" do
      before do
        allow(form).to receive(:start_date).and_return(Time.zone.local(2023, 2, 8))

        allow(form).to receive(:start_year_2024_or_later?).and_return(false)
      end

      it "has correct pages" do
        expect(outright_sale.pages.map(&:id)).to eq(
          %w[
            purchase_price_outright_sale
            about_price_outright_sale_value_check
            mortgage_used_outright_sale
            outright_sale_mortgage_used_mortgage_value_check
            mortgage_amount_outright_sale
            outright_sale_mortgage_amount_mortgage_value_check
            mortgage_lender_outright_sale
            mortgage_lender_other_outright_sale
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

    context "when 2024" do
      before do
        allow(form).to receive(:start_date).and_return(Time.zone.local(2024, 2, 8))
        allow(form).to receive(:start_year_2024_or_later?).and_return(true)
      end

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
      expect(outright_sale.displayed_in_tasklist?(log)).to eq(true)
    end
  end

  context "when it is not a outright sale" do
    let(:log) { FactoryBot.build(:sales_log, ownershipsch: 2) }

    it "is displayed in tasklist" do
      expect(outright_sale.displayed_in_tasklist?(log)).to eq(false)
    end
  end
end

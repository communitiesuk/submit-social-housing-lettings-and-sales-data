require "rails_helper"

RSpec.describe Form::Sales::Subsections::SharedOwnershipScheme, type: :model do
  subject(:shared_ownership_scheme) { described_class.new(subsection_id, subsection_definition, section) }

  let(:subsection_id) { nil }
  let(:subsection_definition) { nil }
  let(:section) { instance_double(Form::Sales::Sections::SaleInformation) }

  it "has correct section" do
    expect(shared_ownership_scheme.section).to eq(section)
  end

  it "has correct pages" do
    expect(shared_ownership_scheme.pages.map(&:id)).to eq(
      %w[
        living_before_purchase_shared_ownership
        staircasing
        about_staircasing
        resale
        exchange_contracts
        handover_date
        la_nominations
        buyer_previous
        previous_bedrooms
        about_price_shared_ownership
        mortgage_used_shared_ownership
        mortgage_amount_shared_ownership
        mortgage_length_shared_ownership
        about_deposit_with_discount
        about_deposit_shared_ownership
        shared_ownership_deposit_value_check
        monthly_rent
        leasehold_charges_shared_ownership
      ],
    )
  end

  it "has the correct id" do
    expect(shared_ownership_scheme.id).to eq("shared_ownership_scheme")
  end

  it "has the correct label" do
    expect(shared_ownership_scheme.label).to eq("Shared ownership scheme")
  end

  it "has the correct depends_on" do
    expect(shared_ownership_scheme.depends_on).to eq([
      {
        "ownershipsch" => 1, "setup_completed?" => true
      },
    ])
  end

  context "when it is a shared ownership scheme" do
    let(:log) { FactoryBot.create(:sales_log, ownershipsch: 1) }

    it "is displayed in tasklist" do
      expect(shared_ownership_scheme.displayed_in_tasklist?(log)).to eq(true)
    end
  end

  context "when it is not a shared ownership scheme" do
    let(:log) { FactoryBot.create(:sales_log, ownershipsch: 2) }

    it "is displayed in tasklist" do
      expect(shared_ownership_scheme.displayed_in_tasklist?(log)).to eq(false)
    end
  end
end

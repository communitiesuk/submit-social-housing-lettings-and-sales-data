require "rails_helper"

RSpec.describe Form::Sales::Pages::PurchasePriceOutrightOwnership, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection, ownershipsch: 1) }

  let(:page_id) { "purchase_price" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[value])
  end

  it "has the correct id" do
    expect(page.id).to eq("purchase_price")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      { "outright_sale_or_discounted_with_full_ownership?" => true },
    ])
  end
end

require "rails_helper"

RSpec.describe Form::Sales::Pages::AddressMatcher, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:log) { build(:sales_log) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[address_line1_input postcode_full_input])
  end

  it "has the correct id" do
    expect(page.id).to eq("address_matcher")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{ "uprn_known" => nil }, { "uprn_known" => 0 }, { "uprn_confirmed" => 0 }])
  end

  it "has the correct skip_href" do
    expect(page.skip_href(log)).to eq(
      "/sales-logs/#{log.id}/property-number-of-bedrooms",
    )
  end
end

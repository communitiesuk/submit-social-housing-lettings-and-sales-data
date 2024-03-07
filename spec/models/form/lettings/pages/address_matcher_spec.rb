require "rails_helper"

RSpec.describe Form::Lettings::Pages::AddressMatcher, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[address_line1_input postcode_full_input])
  end

  it "has the correct id" do
    expect(page.id).to eq("address_matcher")
  end

  it "has the correct header" do
    expect(page.header).to eq("Find an address")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{"is_supported_housing?"=>false, "uprn_known"=>nil}, {"is_supported_housing?"=>false, "uprn_known"=>0}, {"is_supported_housing?"=>false, "uprn_confirmed"=>0}])
  end
end

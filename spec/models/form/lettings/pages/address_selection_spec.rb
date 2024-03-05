require "rails_helper"

RSpec.describe Form::Lettings::Pages::AddressSelection, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:log) { create(:lettings_log) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[address_selection])
  end

  it "has the correct id" do
    expect(page.id).to eq("address_selection")
  end

  it "has the correct header" do
    expect(page.header).to eq("We found some addresses that might be this property")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has the correct skip text" do
    "Search for address again"
  end

  it "has the correct skip_href" do
    expect(page.skip_href(log)).to eq(
      "/lettings-logs/#{log.id}/address-matcher",
    )
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([{ "address_options_present?" => true }])
  end
end

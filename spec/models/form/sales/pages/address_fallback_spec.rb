require "rails_helper"

RSpec.describe Form::Sales::Pages::AddressFallback, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2024, 4, 1))) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[address_line1 address_line2 town_or_city county postcode_full])
  end

  it "has the correct id" do
    expect(page.id).to eq("address")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      { "uprn_known" => nil, "uprn_selection" => "uprn_not_listed" },
      { "uprn_known" => 0, "uprn_selection" => "uprn_not_listed" },
      { "uprn_confirmed" => 0, "uprn_selection" => "uprn_not_listed" },
      { "uprn_known" => nil, "address_options_present?" => false },
      { "uprn_known" => 0, "address_options_present?" => false },
      { "uprn_confirmed" => 0, "address_options_present?" => false },
    ])
  end
end

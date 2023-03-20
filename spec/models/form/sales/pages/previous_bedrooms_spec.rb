require "rails_helper"

RSpec.describe Form::Sales::Pages::PreviousBedrooms, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[frombeds])
  end

  it "has the correct id" do
    expect(page.id).to eq("previous_bedrooms")
  end

  it "has the correct header" do
    expect(page.header).to eq("About the buyers’ previous property")
  end

  it "has the correct description" do
    expect(page.description).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "soctenant" => 1,
      },
      {
        "soctenant" => 0,
      },
    ])
  end
end

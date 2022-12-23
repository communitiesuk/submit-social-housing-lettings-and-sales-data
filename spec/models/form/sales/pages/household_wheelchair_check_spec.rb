require "rails_helper"

RSpec.describe Form::Sales::Pages::HouseholdWheelchairCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "buyer_1_income_mortgage_value_check" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[wheel_value_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("buyer_1_income_mortgage_value_check")
  end

  it "has the correct header" do
    expect(page.header).to eq("")
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "wheelchair_when_not_disabled?" => true,
      },
    ])
  end
end

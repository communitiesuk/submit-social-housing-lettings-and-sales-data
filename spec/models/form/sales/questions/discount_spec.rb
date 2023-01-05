require "rails_helper"

RSpec.describe Form::Sales::Questions::Discount, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("discount")
  end

  it "has the correct header" do
    expect(question.header).to eq("What was the percentage discount?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Percentage discount")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("For Right to Buy (RTB), Preserved Right to Buy (PRTB), and Voluntary Right to Buy (VRTB)</br></br>
    If discount capped, enter capped %</br></br>
    If the property is being sold to an existing tenant under the RTB, PRTB, or VRTB schemes, enter the % discount from the full market value that is being given.")
  end

  it "has correct width" do
    expect(question.width).to eq(5)
  end

  it "has correct suffix" do
    expect(question.suffix).to eq("%")
  end

  it "has correct min" do
    expect(question.min).to eq(0)
  end

  it "has correct max" do
    expect(question.max).to eq(100)
  end
end

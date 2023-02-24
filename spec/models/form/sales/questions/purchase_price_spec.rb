require "rails_helper"

RSpec.describe Form::Sales::Questions::PurchasePrice, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("value")
  end

  it "has the correct header" do
    expect(question.header).to eq("Q100 - What is the full purchase price?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Purchase price")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq(
      "For all schemes, including Right to Acquire (RTA), Right to Buy (RTB), Voluntary Right to Buy (VRTB) or Preserved Right to Buy (PRTB) sales, enter the full price of the property without any discount",
    )
  end

  it "has correct width" do
    expect(question.width).to eq(5)
  end

  it "has correct prefix" do
    expect(question.prefix).to eq("£")
  end

  it "has correct min" do
    expect(question.min).to eq(0)
  end
end

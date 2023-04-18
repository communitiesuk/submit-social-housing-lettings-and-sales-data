require "rails_helper"

RSpec.describe Form::Sales::Questions::Savings, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("savings")
  end

  it "has the correct header" do
    expect(question.header).to eq("Enter their total savings to the nearest £10")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Buyer’s total savings (to nearest £10) before any deposit paid")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to be_nil
  end

  it "has the correct width" do
    expect(question.width).to eq(5)
  end

  it "has correct step" do
    expect(question.step).to eq(1)
  end

  it "has correct prefix" do
    expect(question.prefix).to eq("£")
  end

  it "has correct min" do
    expect(question.min).to eq(0)
  end
end

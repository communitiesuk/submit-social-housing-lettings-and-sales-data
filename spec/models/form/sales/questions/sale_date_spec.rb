require "rails_helper"

RSpec.describe Form::Sales::Questions::SaleDate, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("saledate")
  end

  it "has the correct header" do
    expect(question.header).to eq("Q1 - What is the sale completion date?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Sale completion date")
  end

  it "has the correct type" do
    expect(question.type).to eq("date")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end
end

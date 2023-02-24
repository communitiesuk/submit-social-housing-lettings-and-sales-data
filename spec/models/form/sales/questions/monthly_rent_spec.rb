require "rails_helper"

RSpec.describe Form::Sales::Questions::MonthlyRent, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("mrent")
  end

  it "has the correct header" do
    expect(question.header).to eq("Q97 - What is the basic monthly rent?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Monthly rent")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("Amount paid before any charges")
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

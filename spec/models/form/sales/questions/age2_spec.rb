require "rails_helper"

RSpec.describe Form::Sales::Questions::Age2, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("age2")
  end

  it "has the correct header" do
    expect(question.header).to eq("Age")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Buyer 2’s age")
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
    expect(question.width).to eq(2)
  end

  it "has the correct inferred check answers value" do
    expect(question.inferred_check_answers_value).to eq([{
      "condition" => {
        "age2_known" => 1,
      },
      "value" => "Not known",
    }])
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(2)
  end

  it "has the correct min" do
    expect(question.min).to eq(0)
  end

  it "has the correct max" do
    expect(question.max).to eq(110)
  end

  it "has the correct step" do
    expect(question.step).to be 1
  end
end

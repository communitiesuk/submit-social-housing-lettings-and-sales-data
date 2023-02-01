require "rails_helper"

RSpec.describe Form::Lettings::Questions::Age, type: :model do
  subject(:question) { described_class.new(nil, question_definition, page, person_index:) }

  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 6 }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct header" do
    expect(question.header).to eq("Age")
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

  it "has the correct min" do
    expect(question.min).to eq(0)
  end

  it "has the correct max" do
    expect(question.max).to eq(120)
  end

  it "has the correct id" do
    expect(question.id).to eq("age6")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Person 6’s age")
  end

  it "has the correct width" do
    expect(question.width).to eq(2)
  end

  it "has the correct inferred check answers value" do
    expect(question.inferred_check_answers_value).to eq([{
      "condition" => { "age6_known" => 1 },
      "value" => "Not known",
    }])
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(6)
  end
end

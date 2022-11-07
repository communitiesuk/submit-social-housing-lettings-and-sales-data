require "rails_helper"

RSpec.describe Form::Sales::Questions::HouseholdWheelchair, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("wheel")
  end

  it "has the correct header" do
    expect(question.header).to eq("Does anyone in the household use a wheelchair?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to be_nil
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
      "3" => { "value" => "Don't know" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to be_nil
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("This can be inside or outside the home")
  end
end

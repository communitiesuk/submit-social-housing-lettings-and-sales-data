require "rails_helper"

RSpec.describe Form::Sales::Questions::HouseholdWheelchairCheck, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("wheel_value_check")
  end

  it "has the correct header" do
    expect(question.header).to eq("Are you sure? You said previously that somebody in household uses a wheelchair")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Does anyone in the household use a wheelchair?")
  end

  it "has the correct type" do
    expect(question.type).to eq("interruption_screen")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to be_nil
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    })
  end

  it "has the correct hidden_in_check_answers" do
    expect(question.hidden_in_check_answers).to be true
  end
end

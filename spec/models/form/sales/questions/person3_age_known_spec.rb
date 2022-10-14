require "rails_helper"

RSpec.describe Form::Sales::Questions::Person3AgeKnown, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("age5_known")
  end

  it "has the correct header" do
    expect(question.header).to eq("Do you know person 3’s age?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Person 3’s age known?")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to eq({
      "age5" => [0],
    })
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("")
  end

  it "has the correct hidden_in_check_answers" do
    expect(question.hidden_in_check_answers).to eq(
      {
        "depends_on" => [
          {
            "age5_known" => 0,
          },
        ],
      },
    )
  end
end

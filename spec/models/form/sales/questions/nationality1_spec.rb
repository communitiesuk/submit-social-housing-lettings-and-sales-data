require "rails_helper"

RSpec.describe Form::Sales::Questions::Nationality1, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("national")
  end

  it "has the correct header" do
    expect(question.header).to eq("Q24 - What is buyer 1’s nationality?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Buyer 1’s nationality")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("Buyer 1 is the person in the household who does the most paid work. If it’s a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest.")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "18" => { "value" => "United Kingdom" },
      "17" => { "value" => "Republic of Ireland" },
      "19" => { "value" => "European Economic Area (EEA), excluding ROI" },
      "12" => { "value" => "Other" },
      "13" => { "value" => "Buyer prefers not to say" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to eq({
      "othernational" => [12],
    })
  end

  it "has correct hidden in check answers" do
    expect(question.hidden_in_check_answers).to eq({
      "depends_on" => [
        {
          "national" => 12,
        },
      ],
    })
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(1)
  end

  it "has the correct inferred_check_answers_value" do
    expect(question.inferred_check_answers_value).to eq([
      { "condition" => { "national" => 13 }, "value" => "Prefers not to say" },
    ])
  end
end

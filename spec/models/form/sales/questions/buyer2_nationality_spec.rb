require "rails_helper"

RSpec.describe Form::Sales::Questions::Buyer2Nationality, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to be page
  end

  it "has the correct id" do
    expect(question.id).to eq "nationalbuy2"
  end

  it "has the correct header" do
    expect(question.header).to eq "What is buyer 2’s nationality?"
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq "Buyer 2’s nationality"
  end

  it "has the correct type" do
    expect(question.type).to eq "radio"
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to be nil
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
    expect(question.conditional_for).to be_nil
  end

  it "has correct hidden in check answers" do
    expect(question.hidden_in_check_answers).to be_nil
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to be 2
  end

  it "has the correct inferred_check_answers_value" do
    expect(question.inferred_check_answers_value).to eq([
      { "condition" => { "national" => 13 }, "value" => "Prefers not to say" },
    ])
  end
end

require "rails_helper"

RSpec.describe Form::Sales::Questions::Buyer2EthnicGroup, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("ethnic_group2")
  end

  it "has the correct header" do
    expect(question.header).to eq("Q30 - What is buyer 2’s ethnic group?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Buyer 2’s ethnic group")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to be nil
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "0" => { "value" => "White" },
      "1" => { "value" => "Mixed or Multiple ethnic groups" },
      "17" => { "value" => "Buyer 1 prefers not to say" },
      "2" => { "value" => "Asian or Asian British" },
      "3" => { "value" => "Black, African, Caribbean or Black British" },
      "4" => { "value" => "Arab or other ethnic group" },
      "divider" => { "value" => true },
    })
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(2)
  end

  it "has the correct inferred_check_answers_value" do
    expect(question.inferred_check_answers_value).to eq([{
      "condition" => {
        "ethnic_group2" => 17,
      },
      "value" => "Prefers not to say",
    }])
  end
end

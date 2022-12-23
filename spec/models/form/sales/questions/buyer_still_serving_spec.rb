require "rails_helper"

RSpec.describe Form::Sales::Questions::BuyerStillServing, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("hhregresstill")
  end

  it "has the correct header" do
    expect(question.header).to eq("Is the buyer still serving in the UK armed forces?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Are they still serving in the UK armed forces?")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "4" => { "value" => "Yes" },
      "5" => { "value" => "No" },
      "6" => { "value" => "Buyer prefers not to say" },
      "7" => { "value" => "Don't know" },
    })
  end
end

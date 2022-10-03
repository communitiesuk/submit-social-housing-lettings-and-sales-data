require "rails_helper"

RSpec.describe Form::Sales::Questions::BuyerInterview, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("noint")
  end

  it "has the correct header" do
    expect(question.header).to eq("Was the buyer interviewed for any of the answers you will provide on this log?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Buyer interviewed in person?")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("You should still try to answer all questions even if the buyer wasn't interviewed in person")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "No" },
      "2" => { "value" => "Yes" },

    })
  end
end

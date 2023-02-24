require "rails_helper"

RSpec.describe Form::Sales::Questions::ArmedForcesSpouse, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("armedforcesspouse")
  end

  it "has the correct header" do
    expect(question.header).to eq("Q64 - Are any of the buyers a spouse or civil partner of a UK armed forces regular who died in service within the last 2 years?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Are any of the buyers a spouse or civil partner of a UK armed forces regular who died in service within the last 2 years?")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to be_nil
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

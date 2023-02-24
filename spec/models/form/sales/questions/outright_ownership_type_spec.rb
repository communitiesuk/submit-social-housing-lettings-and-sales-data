require "rails_helper"

RSpec.describe Form::Sales::Questions::OutrightOwnershipType, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("type")
  end

  it "has the correct header" do
    expect(question.header).to eq("Q6 - What is the type of outright sale?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Type of outright sale")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "10" => { "value" => "Outright" },
      "12" => { "value" => "Other sale" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to eq({
      "othtype" => [12],
    })
  end
end

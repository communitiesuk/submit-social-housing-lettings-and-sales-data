require "rails_helper"

RSpec.describe Form::Setup::Questions::NeedsType, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("needstype")
  end

  it "has the correct header" do
    expect(question.header).to eq("What is the needs type?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Needs type")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question).not_to be_derived
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "General needs" },
      "2" => { "value" => "Supported housing" },
    })
  end
end

require "rails_helper"

RSpec.describe Form::Sales::Questions::ArmedForces, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("hhregres")
  end

  it "has the correct header" do
    expect(question.header).to eq("Q62 - Have any of the buyers ever served as a regular in the UK armed forces?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Have any of the buyers ever served as a regular in the UK armed forces?")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("A regular is somebody who has served in the Royal Navy, the Royal Marines, the Royal Airforce or Army full time and does not include reserve forces")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Yes" },
      "7" => { "value" => "No" },
      "3" => { "value" => "Buyer prefers not to say" },
      "8" => { "value" => "Don't know" },
    })
  end
end

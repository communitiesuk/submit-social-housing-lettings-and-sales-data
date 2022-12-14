require "rails_helper"

RSpec.describe Form::Sales::Questions::Person4WorkingSituation, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { "ecstat5" }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("ecstat5")
  end

  it "has the correct header" do
    expect(question.header).to eq("Which of these best describes Person 4’s working situation?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Person 4’s working situation")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has expected check answers card number" do
    expect(question.check_answers_card_number).to eq(5)
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "2" => { "value" => "Part-time - Less than 30 hours" },
      "1" => { "value" => "Full-time - 30 hours or more" },
      "3" => { "value" => "In government training into work, such as New Deal" },
      "4" => { "value" => "Jobseeker" },
      "6" => { "value" => "Not seeking work" },
      "8" => { "value" => "Unable to work due to long term sick or disability" },
      "5" => { "value" => "Retired" },
      "0" => { "value" => "Other" },
      "10" => { "value" => "Buyer prefers not to say" },
      "7" => { "value" => "Full-time student" },
      "9" => { "value" => "Child under 16" },
    })
  end
end

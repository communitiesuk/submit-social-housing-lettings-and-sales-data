require "rails_helper"

RSpec.describe Form::Sales::Questions::Buyer1WorkingSituation, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_2024_or_later?: false))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("ecstat1")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Full-time - 30 hours or more" },
      "2" => { "value" => "Part-time - Less than 30 hours" },
      "3" => { "value" => "In government training into work" },
      "4" => { "value" => "Jobseeker" },
      "6" => { "value" => "Not seeking work" },
      "8" => { "value" => "Unable to work due to long term sick or disability" },
      "5" => { "value" => "Retired" },
      "0" => { "value" => "Other" },
      "10" => { "value" => "Buyer prefers not to say" },
      "7" => { "value" => "Full-time student" },
    })
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(1)
  end

  it "has the correct inferred_check_answers_value" do
    expect(question.inferred_check_answers_value).to eq([
      { "condition" => { "ecstat1" => 10 }, "value" => "Prefers not to say" },
    ])
  end
end

require "rails_helper"

RSpec.describe Form::Sales::Questions::Buyer1AgeKnown, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("age1_known")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
      "2" => { "value" => "Buyer prefers not to say" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to eq({
      "age1" => [0],
    })
  end

  it "has correct hidden_in_check_answers for" do
    expect(question.hidden_in_check_answers).to eq({
      "depends_on" => [
        {
          "age1_known" => 0,
        },
        {
          "age1_known" => 1,
        },
        {
          "age1_known" => 2,
        },
      ],
    })
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(1)
  end
end

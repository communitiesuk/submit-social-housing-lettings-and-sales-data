require "rails_helper"

RSpec.describe Form::Sales::Questions::HasServiceChargesChanged, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, form: instance_double(Form, start_date:)) }
  let(:page) { instance_double(Form::Page, subsection:) }
  let(:start_date) { Time.utc(2026, 5, 1) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("hasservicechargeschanged")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to eq({
      "newservicecharges" => [1],
    })
  end

  it "has correct hidden_in_check_answers for" do
    expect(question.hidden_in_check_answers).to eq({
      "depends_on" => [
        {
          "hasservicechargeschanged" => 1,
        },
      ],
    })
  end

  it "has the correct question number" do
    expect(question.question_number).to eq(0)
  end
end

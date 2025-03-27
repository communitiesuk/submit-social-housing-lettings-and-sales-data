require "rails_helper"

RSpec.describe Form::Sales::Questions::HasServiceCharge, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:form) { instance_double(Form, start_date: Time.zone.local(2025, 4, 4)) }
  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, id: "shared_ownership", form:)) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("has_mscharge")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "0" => { "value" => "No" },
      "1" => { "value" => "Yes" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to eq({
      "mscharge" => [1],
    })
  end

  it "has correct hidden_in_check_answers for" do
    expect(question.hidden_in_check_answers).to eq({
      "depends_on" => [
        {
          "has_mscharge" => 1,
        },
      ],
    })
  end
end

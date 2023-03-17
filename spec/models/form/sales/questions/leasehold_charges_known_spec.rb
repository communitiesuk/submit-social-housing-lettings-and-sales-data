require "rails_helper"

RSpec.describe Form::Sales::Questions::LeaseholdChargesKnown, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 1) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("mscharge_known")
  end

  it "has the correct header" do
    expect(question.header).to eq("Does the property have any monthly leasehold charges?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Monthly leasehold charges known?")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
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

  it "has the correct hint" do
    expect(question.hint_text).to eq("For example, service and management charges")
  end

  it "has correct hidden_in_check_answers for" do
    expect(question.hidden_in_check_answers).to eq({
      "depends_on" => [
        {
          "mscharge_known" => 1,
        },
      ],
    })
  end
end

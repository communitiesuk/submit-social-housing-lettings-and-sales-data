require "rails_helper"

RSpec.describe Form::Sales::Questions::Age1, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("age1")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct width" do
    expect(question.width).to eq(2)
  end

  it "has the correct inferred check answers value" do
    expect(question.inferred_check_answers_value).to eq([
      {
        "condition" => { "age1_known" => 1 },
        "value" => "Not known",
      },
      {
        "condition" => { "age1_known" => 2 },
        "value" => "Prefers not to say",
      },
    ])
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(1)
  end

  it "has the correct min" do
    expect(question.min).to eq(16)
  end

  it "has the correct max" do
    expect(question.max).to eq(110)
  end
end

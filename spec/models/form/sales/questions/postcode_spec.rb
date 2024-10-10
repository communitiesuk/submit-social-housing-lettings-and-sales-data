require "rails_helper"

RSpec.describe Form::Sales::Questions::Postcode, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("postcode_full")
  end

  it "has the correct type" do
    expect(question.type).to eq("text")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct width" do
    expect(question.width).to eq(5)
  end

  it "has the correct inferred_answers" do
    expect(question.inferred_answers).to eq({
      "la" => {
        "is_la_inferred" => true,
      },
    })
  end

  it "has the correct inferred_check_answers_value" do
    expect(question.inferred_check_answers_value).to eq([{
      "condition" => {
        "pcodenk" => 1,
      },
      "value" => "Not known",
    }])
  end
end

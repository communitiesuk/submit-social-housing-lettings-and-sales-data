require "rails_helper"

RSpec.describe Form::Sales::Questions::PropertyPostcode, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("postcode_known")
  end

  it "has the correct header" do
    expect(question.header).to eq("Do you know the property's postcode?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Do you know the property's postcode?")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Yes" },
      "0" => { "value" => "No" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to eq({
      "postcode_full" => [1],
    })
  end
end

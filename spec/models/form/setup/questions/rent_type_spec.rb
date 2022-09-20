require "rails_helper"

RSpec.describe Form::Setup::Questions::RentType, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("rent_type")
  end

  it "has the correct header" do
    expect(question.header).to eq("What is the rent type?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Rent type")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("")
  end

  it "has the correct conditional_for" do
    expect(question.conditional_for).to eq({ "irproduct_other" => [5] })
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Affordable Rent" },
      "2" => { "value" => "London Affordable Rent" },
      "4" => { "value" => "London Living Rent" },
      "3" => { "value" => "Rent to Buy" },
      "0" => { "value" => "Social Rent" },
      "5" => { "value" => "Other intermediate rent product" },
    })
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end
end

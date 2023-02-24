require "rails_helper"

RSpec.describe Form::Sales::Questions::DiscountedOwnershipType, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("type")
  end

  it "has the correct header" do
    expect(question.header).to eq("Q5 - What is the type of discounted ownership sale?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Type of discounted ownership sale")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "8" => { "value" => "Right to Acquire (RTA)" },
      "14" => { "value" => "Preserved Right to Buy (PRTB)" },
      "27" => { "value" => "Voluntary Right to Buy (VRTB)" },
      "9" => { "value" => "Right to Buy (RTB)" },
      "29" => { "value" => "Rent to Buy - Full Ownership" },
      "21" => { "value" => "Social HomeBuy for outright purchase" },
      "22" => { "value" => "Any other equity loan scheme" },
    })
  end
end

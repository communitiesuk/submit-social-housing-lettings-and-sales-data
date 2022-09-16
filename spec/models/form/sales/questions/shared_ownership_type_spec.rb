require "rails_helper"

RSpec.describe Form::Sales::Questions::SharedOwnershipType, type: :model do
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
    expect(question.header).to eq("What is the type of shared ownership sale?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Type of shared ownership sale")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("A shared ownership sale is when the purchaser buys up to 75% of the property value and pays rent ro the Private Registered Provider (PRP) on the remaining portion")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "2" => { "value" => "Shared Ownership" },
      "24" => { "value" => "Old Persons Shared Ownership" },
      "18" => { "value" => "Social HomeBuy (shared ownership purchase)" },
      "16" => { "value" => "Home Ownership for people with Long Term Disabilities (HOLD)" },
      "28" => { "value" => "Rent to Buy - Shared Ownership" },
      "31" => { "value" => "Right to Shared Ownership" },
      "30" => { "value" => "Shared Ownership - 2021 model lease" },
    })
  end
end

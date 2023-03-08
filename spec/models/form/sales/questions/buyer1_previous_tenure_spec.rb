require "rails_helper"

RSpec.describe Form::Sales::Questions::Buyer1PreviousTenure, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }
  let(:log) { create(:sales_log) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("prevten")
  end

  it "has the correct header" do
    expect(question.header).to eq("What was buyer 1’s previous tenure?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Buyer 1’s previous tenure")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Local Authority" },
      "2" => { "value" => "Private registered provider or housing association tenant" },
      "3" => { "value" => "Private tenant" },
      "4" => { "value" => "Tied home or renting with job" },
      "5" => { "value" => "Owner occupier" },
      "6" => { "value" => "Living with family or friends" },
      "7" => { "value" => "Temporary accomodation" },
      "9" => { "value" => "Other" },
      "0" => { "value" => "Don’t know" },
    })
  end
end

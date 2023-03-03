require "rails_helper"

RSpec.describe Form::Lettings::Questions::PreviousLetType, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq page
  end

  it "has the correct id" do
    expect(question.id).to eq "unitletas"
  end

  it "has the correct header" do
    expect(question.header).to eq "What type was the property most recently let as?"
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq "Most recent let type"
  end

  it "has the correct type" do
    expect(question.type).to eq "radio"
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq ""
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct answer options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Social rent basis" },
      "2" => { "value" => "Affordable rent basis" },
      "5" => { "value" => "A London Affordable Rent basis" },
      "6" => { "value" => "A Rent to Buy basis" },
      "7" => { "value" => "A London Living Rent basis" },
      "8" => { "value" => "Another Intermediate Rent basis" },
      "divider" => { "value" => true },
      "3" => { "value" => "Don’t know" },
    })
  end
end

require "rails_helper"

RSpec.describe Form::Sales::Questions::Buyer2LivingIn, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq page
  end

  it "has the correct id" do
    expect(question.id).to eq "buy2living"
  end

  it "has the correct header" do
    expect(question.header).to eq "At the time of purchase, was buyer 2 living at the same address as buyer 1?"
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq "Buyer 2 living at the same address"
  end

  it "has the correct type" do
    expect(question.type).to eq "radio"
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq ""
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
      "3" => { "value" => "Don't know" },
    })
  end
end

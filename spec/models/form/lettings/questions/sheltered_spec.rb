require "rails_helper"

RSpec.describe Form::Lettings::Questions::Sheltered, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq page
  end

  it "has the correct id" do
    expect(question.id).to eq "sheltered"
  end

  it "has the correct header" do
    expect(question.header).to eq "Is this letting in sheltered accommodation?"
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq "Is this letting in sheltered accommodation?"
  end

  it "has the correct type" do
    expect(question.type).to eq "radio"
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq ""
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "2" => { "value" => "Yes – extra care housing" },
      "1" => { "value" => "Yes – specialist retirement housing" },
      "5" => { "value" => "Yes – sheltered housing for adults aged under 55 years" },
      "3" => { "value" => "No" },
      "divider" => { "value" => true },
      "4" => { "value" => "Don’t know" },
    })
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end
end

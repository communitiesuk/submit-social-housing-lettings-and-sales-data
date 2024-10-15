require "rails_helper"

RSpec.describe Form::Lettings::Questions::PartnerUnder16ValueCheck, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index: 1) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("partner_under_16_value_check")
  end

  it "has the correct type" do
    expect(question.type).to eq("interruption_screen")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has a correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(1)
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    })
  end

  it "has the correct hidden_in_check_answers" do
    expect(question.hidden_in_check_answers).to eq({
      "depends_on" => [
        {
          "partner_under_16_value_check" => 0,
        },
        {
          "partner_under_16_value_check" => 1,
        },
      ],
    })
  end
end

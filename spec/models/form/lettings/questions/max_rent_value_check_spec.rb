require "rails_helper"

RSpec.describe Form::Lettings::Questions::MaxRentValueCheck, type: :model do
  subject(:question) { described_class.new(nil, question_definition, page, check_answers_card_number:) }

  let(:question_definition) { nil }
  let(:check_answers_card_number) { nil }
  let(:page) { instance_double(Form::Page) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("rent_value_check")
  end

  it "has the correct header" do
    expect(question.header).to eq("Are you sure this is correct?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Total rent confirmation")
  end

  it "has the correct type" do
    expect(question.type).to eq("interruption_screen")
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("This is higher than we would expect. Check:<ul class=\"govuk-body-l app-panel--interruption\"><li>the decimal point</li><li>the frequency, for example every week or every calendar month</li><li>the rent type is correct, for example affordable or social rent</li></ul>")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    })
  end

  it "has the correct hidden_in_check_answers" do
    expect(question.hidden_in_check_answers).to eq({ "depends_on" => [{ "rent_value_check" => 0 }, { "rent_value_check" => 1 }] })
  end
end

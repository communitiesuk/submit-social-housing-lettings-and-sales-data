require "rails_helper"

RSpec.describe Form::Sales::Questions::Buyer1IncomeKnown, type: :model do
  include CollectionTimeHelper
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: collection_start_date_for_year(current_collection_start_year)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("income1nk")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to eq({
      "income1" => [0],
    })
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(1)
  end

  it "has the correct hint_text" do
    expect(question.hint_text).to eq("Provide the gross annual income (i.e. salary before tax) plus the annual amount of benefits, Universal Credit or pensions, and income from investments.")
  end
end

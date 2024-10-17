require "rails_helper"

RSpec.describe Form::Sales::Questions::AddressLine1ForAddressMatcher, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:log) { build(:sales_log, :in_progress, address_line1_input: "Address line 1", postcode_full_input: "AA1 1AA") }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("address_line1_input")
  end

  it "has the correct error label" do
    expect(question.error_label).to eq("Address line 1")
  end

  it "has the correct question_number" do
    expect(question.question_number).to eq(nil)
  end

  it "has the correct type" do
    expect(question.type).to eq("text")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer label" do
    expect(question.answer_label(log)).to eq("Address line 1\nAA1 1AA")
  end

  it "has the correct inferred check answers value" do
    expect(question.inferred_check_answers_value).to be_nil
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to be_nil
  end

  it "has the correct disable_clearing_if_not_routed_or_dynamic_answer_options value" do
    expect(question.disable_clearing_if_not_routed_or_dynamic_answer_options).to eq(true)
  end
end

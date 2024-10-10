require "rails_helper"

RSpec.describe Form::Sales::Questions::NationalityAllGroup, type: :model do
  subject(:question) { described_class.new("some_id", nil, page, buyer_index) }

  let(:buyer_index) { 1 }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_after_2024?: false))) }

  it "has correct page" do
    expect(question.page).to be page
  end

  it "has the correct id" do
    expect(question.id).to eq "some_id"
  end

  it "has the correct type" do
    expect(question.type).to eq "radio"
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "826" => { "value" => "United Kingdom" },
      "12" => { "value" => "Other" },
      "0" => { "value" => "Buyer prefers not to say" },
    })
  end

  it "has correct hidden in check answers" do
    expect(question.hidden_in_check_answers).to eq({ "depends_on" => [{ "some_id" => 12 }] })
  end

  context "with buyer 1" do
    let(:buyer_index) { 1 }

    it "has correct conditional for" do
      expect(question.conditional_for).to eq({ "nationality_all" => [12] })
    end

    it "has correct question_number" do
      expect(question.question_number).to eq(24)
    end

    it "has correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(1)
    end
  end

  context "with buyer 2" do
    let(:buyer_index) { 2 }

    it "has correct conditional for" do
      expect(question.conditional_for).to eq({ "nationality_all_buyer2" => [12] })
    end

    it "has correct question_number" do
      expect(question.question_number).to eq(32)
    end

    it "has correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(2)
    end
  end
end

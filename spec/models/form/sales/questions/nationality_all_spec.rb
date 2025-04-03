require "rails_helper"

RSpec.describe Form::Sales::Questions::NationalityAll, type: :model do
  subject(:question) { described_class.new("some_id", nil, page, buyer_index) }

  let(:buyer_index) { 1 }

  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to be page
  end

  it "has the correct id" do
    expect(question.id).to eq "some_id"
  end

  it "has the correct type" do
    expect(question.type).to eq "select"
  end

  it "has the correct answer_options" do
    expect(question.answer_options.count).to eq(202)
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to be_nil
  end

  it "has correct hidden in check answers" do
    expect(question.hidden_in_check_answers).to be_nil
  end

  context "with buyer 1" do
    let(:buyer_index) { 1 }

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to be 1
    end

    it "has the correct question_number" do
      expect(question.question_number).to be 24
    end
  end

  context "with buyer 2" do
    let(:buyer_index) { 2 }

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to be 2
    end

    it "has the correct question_number" do
      expect(question.question_number).to be 32
    end
  end
end

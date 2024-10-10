require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonKnown, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "details_known_1" }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 2 }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
    })
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to be_nil
  end

  it "has the correct hidden_in_check_answers" do
    expect(question.hidden_in_check_answers).to be_nil
  end

  context "with person 2" do
    let(:question_id) { "details_known_2" }
    let(:person_index) { 2 }

    it "has the correct id" do
      expect(question.id).to eq("details_known_2")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(2)
    end
  end

  context "with person 3" do
    let(:question_id) { "details_known_3" }
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("details_known_3")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(3)
    end
  end

  context "with person 4" do
    let(:question_id) { "details_known_4" }
    let(:person_index) { 4 }

    it "has the correct id" do
      expect(question.id).to eq("details_known_4")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(4)
    end
  end

  context "with person 5" do
    let(:question_id) { "details_known_5" }
    let(:person_index) { 5 }

    it "has the correct id" do
      expect(question.id).to eq("details_known_5")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(5)
    end
  end
end

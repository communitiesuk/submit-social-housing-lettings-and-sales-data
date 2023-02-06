require "rails_helper"

RSpec.describe Form::Lettings::Questions::DetailsKnown, type: :model do
  subject(:question) { described_class.new(nil, question_definition, page, person_index:) }

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
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("You must provide details for everyone in the household if you know them.")
  end

  context "with person 2" do
    it "has the correct id" do
      expect(question.id).to eq("details_known_2")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Details known for person 2")
    end

    it "has the correct header" do
      expect(question.header).to eq("Do you know details for person 2?")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(2)
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("details_known_3")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Details known for person 3")
    end

    it "has the correct header" do
      expect(question.header).to eq("Do you know details for person 3?")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(3)
    end
  end
end

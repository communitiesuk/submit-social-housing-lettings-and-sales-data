require "rails_helper"

RSpec.describe Form::Lettings::Questions::PersonRelationship, type: :model do
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

  it "has the correct answer_options" do
    expect(question.answer_options).to eq("C" => { "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education.", "value" => "Child" },
                                          "P" => { "value" => "Partner" },
                                          "R" => { "value" => "Person prefers not to say" },
                                          "X" => { "value" => "Other" },
                                          "divider" => { "value" => true })
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("")
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to be nil
  end

  it "has the correct hidden_in_check_answers" do
    expect(question.hidden_in_check_answers).to be nil
  end

  context "with person 2" do
    it "has the correct id" do
      expect(question.id).to eq("relat2")
    end

    it "has the correct header" do
      expect(question.header).to eq("What is person 2’s relationship to the lead tenant?")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(2)
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 2’s relationship to the lead tenant")
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("relat3")
    end

    it "has the correct header" do
      expect(question.header).to eq("What is person 3’s relationship to the lead tenant?")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(3)
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 3’s relationship to the lead tenant")
    end
  end
end

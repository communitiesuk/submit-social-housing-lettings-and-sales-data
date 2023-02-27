require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonRelationshipToBuyer1, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "relat2" }
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

  it "has expected check answers card number" do
    expect(question.check_answers_card_number).to eq(2)
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "P" => { "value" => "Partner" },
      "C" => { "value" => "Child", "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education." },
      "X" => { "value" => "Other" },
      "R" => { "value" => "Person prefers not to say" },
    })
  end

  context "when person 2" do
    let(:question_id) { "relat2" }
    let(:person_index) { 2 }

    it "has the correct id" do
      expect(question.id).to eq("relat2")
    end

    it "has the correct header" do
      expect(question.header).to eq("Q36 - What is Person 2’s relationship to Buyer 1?")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 2’s relationship to Buyer 1")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(2)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "relat2" => "R" }, "value" => "Prefers not to say" },
      ])
    end
  end

  context "when person 3" do
    let(:question_id) { "relat3" }
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("relat3")
    end

    it "has the correct header" do
      expect(question.header).to eq("Q40 - What is Person 3’s relationship to Buyer 1?")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 3’s relationship to Buyer 1")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(3)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "relat3" => "R" }, "value" => "Prefers not to say" },
      ])
    end
  end

  context "when person 4" do
    let(:question_id) { "relat4" }
    let(:person_index) { 4 }

    it "has the correct id" do
      expect(question.id).to eq("relat4")
    end

    it "has the correct header" do
      expect(question.header).to eq("Q44 - What is Person 4’s relationship to Buyer 1?")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 4’s relationship to Buyer 1")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(4)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "relat4" => "R" }, "value" => "Prefers not to say" },
      ])
    end
  end

  context "when person 5" do
    let(:question_id) { "relat5" }
    let(:person_index) { 5 }

    it "has the correct id" do
      expect(question.id).to eq("relat5")
    end

    it "has the correct header" do
      expect(question.header).to eq("Q48 - What is Person 5’s relationship to Buyer 1?")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 5’s relationship to Buyer 1")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(5)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "relat5" => "R" }, "value" => "Prefers not to say" },
      ])
    end
  end
end

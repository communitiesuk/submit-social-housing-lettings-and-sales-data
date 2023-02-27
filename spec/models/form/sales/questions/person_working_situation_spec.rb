require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonWorkingSituation, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "ecstat2" }
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
    expect(question.answer_options).to eq({
      "2" => { "value" => "Part-time - Less than 30 hours" },
      "1" => { "value" => "Full-time - 30 hours or more" },
      "3" => { "value" => "In government training into work, such as New Deal" },
      "4" => { "value" => "Jobseeker" },
      "6" => { "value" => "Not seeking work" },
      "8" => { "value" => "Unable to work due to long term sick or disability" },
      "5" => { "value" => "Retired" },
      "0" => { "value" => "Other" },
      "10" => { "value" => "Person prefers not to say" },
      "7" => { "value" => "Full-time student" },
      "9" => { "value" => "Child under 16" },
    })
  end

  context "when person 2" do
    let(:question_id) { "ecstat2" }
    let(:person_index) { 2 }

    it "has the correct id" do
      expect(question.id).to eq("ecstat2")
    end

    it "has the correct header" do
      expect(question.header).to eq("Q39 - Which of these best describes Person 2’s working situation?")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 2’s working situation")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(2)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "ecstat2" => 10 }, "value" => "Prefers not to say" },
      ])
    end
  end

  context "when person 3" do
    let(:question_id) { "ecstat3" }
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("ecstat3")
    end

    it "has the correct header" do
      expect(question.header).to eq("Q43 - Which of these best describes Person 3’s working situation?")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 3’s working situation")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(3)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "ecstat3" => 10 }, "value" => "Prefers not to say" },
      ])
    end
  end

  context "when person 4" do
    let(:question_id) { "ecstat4" }
    let(:person_index) { 4 }

    it "has the correct id" do
      expect(question.id).to eq("ecstat4")
    end

    it "has the correct header" do
      expect(question.header).to eq("Q47 - Which of these best describes Person 4’s working situation?")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 4’s working situation")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(4)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "ecstat4" => 10 }, "value" => "Prefers not to say" },
      ])
    end
  end

  context "when person 5" do
    let(:question_id) { "ecstat5" }
    let(:person_index) { 5 }

    it "has the correct id" do
      expect(question.id).to eq("ecstat5")
    end

    it "has the correct header" do
      expect(question.header).to eq("Q51 - Which of these best describes Person 5’s working situation?")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 5’s working situation")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(5)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "ecstat5" => 10 }, "value" => "Prefers not to say" },
      ])
    end
  end
end

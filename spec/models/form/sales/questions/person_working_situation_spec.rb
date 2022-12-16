require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonWorkingSituation, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "ecstat2" }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 2 }

  before do
    allow(page).to receive(:id).and_return("person_1_working_situation")
  end

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

  context "when person 1" do
    context "and not joint purchase" do
      let(:question_id) { "ecstat2" }
      let(:person_index) { 2 }

      before do
        allow(page).to receive(:id).and_return("person_1_working_situation")
      end

      it "has the correct id" do
        expect(question.id).to eq("ecstat2")
      end

      it "has the correct header" do
        expect(question.header).to eq("Which of these best describes Person 1’s working situation?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 1’s working situation")
      end

      it "has expected check answers card number" do
        expect(question.check_answers_card_number).to eq(2)
      end
    end

    context "and joint purchase" do
      let(:person_index) { 3 }
      let(:question_id) { "ecstat3" }

      before do
        allow(page).to receive(:id).and_return("person_1_working_situation_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("ecstat3")
      end

      it "has the correct header" do
        expect(question.header).to eq("Which of these best describes Person 1’s working situation?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 1’s working situation")
      end

      it "has expected check answers card number" do
        expect(question.check_answers_card_number).to eq(3)
      end
    end
  end

  context "when person 2" do
    context "and not joint purchase" do
      let(:question_id) { "ecstat3" }
      let(:person_index) { 3 }

      before do
        allow(page).to receive(:id).and_return("person_2_working_situation")
      end

      it "has the correct id" do
        expect(question.id).to eq("ecstat3")
      end

      it "has the correct header" do
        expect(question.header).to eq("Which of these best describes Person 2’s working situation?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 2’s working situation")
      end

      it "has expected check answers card number" do
        expect(question.check_answers_card_number).to eq(3)
      end
    end

    context "and joint purchase" do
      let(:question_id) { "ecstat4" }
      let(:person_index) { 4 }

      before do
        allow(page).to receive(:id).and_return("person_2_working_situation_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("ecstat4")
      end

      it "has the correct header" do
        expect(question.header).to eq("Which of these best describes Person 2’s working situation?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 2’s working situation")
      end

      it "has expected check answers card number" do
        expect(question.check_answers_card_number).to eq(4)
      end
    end
  end

  context "when person 3" do
    context "and not joint purchase" do
      let(:question_id) { "ecstat4" }
      let(:person_index) { 4 }

      before do
        allow(page).to receive(:id).and_return("person_3_working_situation")
      end

      it "has the correct id" do
        expect(question.id).to eq("ecstat4")
      end

      it "has the correct header" do
        expect(question.header).to eq("Which of these best describes Person 3’s working situation?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 3’s working situation")
      end

      it "has expected check answers card number" do
        expect(question.check_answers_card_number).to eq(4)
      end
    end

    context "and joint purchase" do
      let(:question_id) { "ecstat5" }
      let(:person_index) { 5 }

      before do
        allow(page).to receive(:id).and_return("person_3_working_situation_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("ecstat5")
      end

      it "has the correct header" do
        expect(question.header).to eq("Which of these best describes Person 3’s working situation?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 3’s working situation")
      end

      it "has expected check answers card number" do
        expect(question.check_answers_card_number).to eq(5)
      end
    end
  end

  context "when person 4" do
    context "and not joint purchase" do
      let(:question_id) { "ecstat5" }
      let(:person_index) { 5 }

      before do
        allow(page).to receive(:id).and_return("person_4_working_situation")
      end

      it "has the correct id" do
        expect(question.id).to eq("ecstat5")
      end

      it "has the correct header" do
        expect(question.header).to eq("Which of these best describes Person 4’s working situation?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 4’s working situation")
      end

      it "has expected check answers card number" do
        expect(question.check_answers_card_number).to eq(5)
      end
    end

    context "and joint purchase" do
      let(:question_id) { "ecstat6" }
      let(:person_index) { 6 }

      before do
        allow(page).to receive(:id).and_return("person_4_working_situation_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("ecstat6")
      end

      it "has the correct header" do
        expect(question.header).to eq("Which of these best describes Person 4’s working situation?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 4’s working situation")
      end

      it "has expected check answers card number" do
        expect(question.check_answers_card_number).to eq(6)
      end
    end
  end
end

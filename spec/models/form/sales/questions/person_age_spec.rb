require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonAge, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index) }

  let(:question_id) { "age3" }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 2 }

  before do
    allow(page).to receive(:id).and_return("person_1_age")
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct header" do
    expect(question.header).to eq("Age")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  it "has the correct hint" do
    expect(question.hint_text).to be_nil
  end

  context "with not a joint purchase" do
    context "and person 1" do
      let(:person_index) { 2 }
      let(:question_id) { "age2" }

      before do
        allow(page).to receive(:id).and_return("person_1_age")
      end

      it "has the correct id" do
        expect(question.id).to eq("age2")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 1’s age")
      end

      it "has the correct width" do
        expect(question.width).to eq(3)
      end

      it "has the correct inferred check answers value" do
        expect(question.inferred_check_answers_value).to eq({
          "condition" => { "age2_known" => 1 },
          "value" => "Not known",
        })
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(2)
      end
    end

    context "and person 2" do
      let(:person_index) { 3 }
      let(:question_id) { "age3" }

      before do
        allow(page).to receive(:id).and_return("person_2_age")
      end

      it "has the correct id" do
        expect(question.id).to eq("age3")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 2’s age")
      end

      it "has the correct width" do
        expect(question.width).to eq(3)
      end

      it "has the correct inferred check answers value" do
        expect(question.inferred_check_answers_value).to eq({
          "condition" => { "age3_known" => 1 },
          "value" => "Not known",
        })
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(3)
      end
    end

    context "and person 3" do
      let(:person_index) { 4 }
      let(:question_id) { "age4" }

      before do
        allow(page).to receive(:id).and_return("person_3_age")
      end

      it "has the correct id" do
        expect(question.id).to eq("age4")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 3’s age")
      end

      it "has the correct width" do
        expect(question.width).to eq(3)
      end

      it "has the correct inferred check answers value" do
        expect(question.inferred_check_answers_value).to eq({
          "condition" => { "age4_known" => 1 },
          "value" => "Not known",
        })
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(4)
      end
    end

    context "and person 4" do
      let(:person_index) { 5 }
      let(:question_id) { "age5" }

      before do
        allow(page).to receive(:id).and_return("person_4_age")
      end

      it "has the correct id" do
        expect(question.id).to eq("age5")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 4’s age")
      end

      it "has the correct width" do
        expect(question.width).to eq(3)
      end

      it "has the correct inferred check answers value" do
        expect(question.inferred_check_answers_value).to eq({
          "condition" => { "age5_known" => 1 },
          "value" => "Not known",
        })
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(5)
      end
    end
  end

  context "with a joint purchase" do
    context "and person 1" do
      let(:person_index) { 3 }
      let(:question_id) { "age3" }

      before do
        allow(page).to receive(:id).and_return("person_1_age_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("age3")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 1’s age")
      end

      it "has the correct width" do
        expect(question.width).to eq(3)
      end

      it "has the correct inferred check answers value" do
        expect(question.inferred_check_answers_value).to eq({
          "condition" => { "age3_known" => 1 },
          "value" => "Not known",
        })
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(3)
      end
    end

    context "and person 2" do
      let(:person_index) { 4 }
      let(:question_id) { "age4" }

      before do
        allow(page).to receive(:id).and_return("person_2_age_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("age4")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 2’s age")
      end

      it "has the correct width" do
        expect(question.width).to eq(3)
      end

      it "has the correct inferred check answers value" do
        expect(question.inferred_check_answers_value).to eq({
          "condition" => { "age4_known" => 1 },
          "value" => "Not known",
        })
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(4)
      end
    end

    context "and person 3" do
      let(:person_index) { 5 }
      let(:question_id) { "age5" }

      before do
        allow(page).to receive(:id).and_return("person_3_age_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("age5")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 3’s age")
      end

      it "has the correct width" do
        expect(question.width).to eq(3)
      end

      it "has the correct inferred check answers value" do
        expect(question.inferred_check_answers_value).to eq({
          "condition" => { "age5_known" => 1 },
          "value" => "Not known",
        })
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(5)
      end
    end

    context "and person 4" do
      let(:person_index) { 6 }
      let(:question_id) { "age6" }

      before do
        allow(page).to receive(:id).and_return("person_4_age_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("age6")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 4’s age")
      end

      it "has the correct width" do
        expect(question.width).to eq(3)
      end

      it "has the correct inferred check answers value" do
        expect(question.inferred_check_answers_value).to eq({
          "condition" => { "age6_known" => 1 },
          "value" => "Not known",
        })
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(6)
      end
    end
  end
end

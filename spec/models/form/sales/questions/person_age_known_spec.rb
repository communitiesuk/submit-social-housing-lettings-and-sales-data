require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonAgeKnown, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "age3_known" }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 2 }

  before do
    allow(page).to receive(:id).and_return("person_1_age")
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

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    })
  end

  it "has the correct hint" do
    expect(question.hint_text).to be_nil
  end

  context "with a non joint purchase" do
    context "and person 1" do
      let(:question_id) { "age2_known" }
      let(:person_index) { 2 }

      before do
        allow(page).to receive(:id).and_return("person_1_age")
      end

      it "has the correct id" do
        expect(question.id).to eq("age2_known")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know person 1’s age?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 1’s age known?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to eq({
          "age2" => [0],
        })
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          {
            "depends_on" => [
              {
                "age2_known" => 0,
              },
              {
                "age2_known" => 1,
              },
            ],
          },
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(2)
      end
    end

    context "and person 2" do
      let(:question_id) { "age3_known" }
      let(:person_index) { 3 }

      before do
        allow(page).to receive(:id).and_return("person_2_age")
      end

      it "has the correct id" do
        expect(question.id).to eq("age3_known")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know person 2’s age?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 2’s age known?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to eq({
          "age3" => [0],
        })
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          {
            "depends_on" => [
              {
                "age3_known" => 0,
              },
              {
                "age3_known" => 1,
              },
            ],
          },
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(3)
      end
    end

    context "and person 3" do
      let(:question_id) { "age4_known" }
      let(:person_index) { 4 }

      before do
        allow(page).to receive(:id).and_return("person_3_age")
      end

      it "has the correct id" do
        expect(question.id).to eq("age4_known")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know person 3’s age?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 3’s age known?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to eq({
          "age4" => [0],
        })
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          {
            "depends_on" => [
              {
                "age4_known" => 0,
              },
              {
                "age4_known" => 1,
              },
            ],
          },
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(4)
      end
    end

    context "and person 4" do
      let(:question_id) { "age5_known" }
      let(:person_index) { 5 }

      before do
        allow(page).to receive(:id).and_return("person_4_age")
      end

      it "has the correct id" do
        expect(question.id).to eq("age5_known")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know person 4’s age?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 4’s age known?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to eq({
          "age5" => [0],
        })
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          {
            "depends_on" => [
              {
                "age5_known" => 0,
              },
              {
                "age5_known" => 1,
              },
            ],
          },
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(5)
      end
    end
  end

  context "with a joint purchase" do
    context "and person 1" do
      let(:question_id) { "age3_known" }
      let(:person_index) { 3 }

      before do
        allow(page).to receive(:id).and_return("person_1_age_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("age3_known")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know person 1’s age?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 1’s age known?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to eq({
          "age3" => [0],
        })
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          {
            "depends_on" => [
              {
                "age3_known" => 0,
              },
              {
                "age3_known" => 1,
              },
            ],
          },
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(3)
      end
    end

    context "and person 2" do
      let(:question_id) { "age4_known" }
      let(:person_index) { 4 }

      before do
        allow(page).to receive(:id).and_return("person_2_age_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("age4_known")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know person 2’s age?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 2’s age known?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to eq({
          "age4" => [0],
        })
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          {
            "depends_on" => [
              {
                "age4_known" => 0,
              },
              {
                "age4_known" => 1,
              },
            ],
          },
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(4)
      end
    end

    context "and person 3" do
      let(:question_id) { "age5_known" }
      let(:person_index) { 5 }

      before do
        allow(page).to receive(:id).and_return("person_3_age_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("age5_known")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know person 3’s age?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 3’s age known?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to eq({
          "age5" => [0],
        })
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          {
            "depends_on" => [
              {
                "age5_known" => 0,
              },
              {
                "age5_known" => 1,
              },
            ],
          },
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(5)
      end
    end

    context "and person 4" do
      let(:question_id) { "age6_known" }
      let(:person_index) { 6 }

      before do
        allow(page).to receive(:id).and_return("person_4_age_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("age6_known")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know person 4’s age?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Person 4’s age known?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to eq({
          "age6" => [0],
        })
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          {
            "depends_on" => [
              {
                "age6_known" => 0,
              },
              {
                "age6_known" => 1,
              },
            ],
          },
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(6)
      end
    end
  end
end

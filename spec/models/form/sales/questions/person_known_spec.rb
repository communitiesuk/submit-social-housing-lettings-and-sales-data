require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonKnown, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "details_known_1" }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 2 }

  before do
    allow(page).to receive(:id).and_return("person_1_known")
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
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
    })
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("")
  end

  context "with a non joint purchase" do
    context "and person 1" do
      let(:question_id) { "details_known_1" }
      let(:person_index) { 2 }

      before do
        allow(page).to receive(:id).and_return("person_1_known")
      end

      it "has the correct id" do
        expect(question.id).to eq("details_known_1")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know the details for person 1?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Details known for person 1?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to be_nil
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          "depends_on" => [{ "details_known_1" => 1 }],
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(2)
      end
    end

    context "and person 2" do
      let(:question_id) { "details_known_2" }
      let(:person_index) { 3 }

      before do
        allow(page).to receive(:id).and_return("person_2_known")
      end

      it "has the correct id" do
        expect(question.id).to eq("details_known_2")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know the details for person 2?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Details known for person 2?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to be_nil
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          "depends_on" => [{ "details_known_2" => 1 }],
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(3)
      end
    end

    context "and person 3" do
      let(:question_id) { "details_known_3" }
      let(:person_index) { 4 }

      before do
        allow(page).to receive(:id).and_return("person_3_known")
      end

      it "has the correct id" do
        expect(question.id).to eq("details_known_3")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know the details for person 3?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Details known for person 3?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to be_nil
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          "depends_on" => [{ "details_known_3" => 1 }],
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(4)
      end
    end

    context "and person 4" do
      let(:question_id) { "details_known_4" }
      let(:person_index) { 5 }

      before do
        allow(page).to receive(:id).and_return("person_4_known")
      end

      it "has the correct id" do
        expect(question.id).to eq("details_known_4")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know the details for person 4?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Details known for person 4?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to be_nil
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          "depends_on" => [{ "details_known_4" => 1 }],
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(5)
      end
    end
  end

  context "with a joint purchase" do
    context "and person 1" do
      let(:question_id) { "details_known_1" }
      let(:person_index) { 3 }

      before do
        allow(page).to receive(:id).and_return("person_1_known_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("details_known_1")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know the details for person 1?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Details known for person 1?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to be_nil
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          "depends_on" => [{ "details_known_1" => 1 }],
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(3)
      end
    end

    context "and person 2" do
      let(:question_id) { "details_known_2" }
      let(:person_index) { 4 }

      before do
        allow(page).to receive(:id).and_return("person_2_known_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("details_known_2")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know the details for person 2?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Details known for person 2?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to be_nil
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          "depends_on" => [{ "details_known_2" => 1 }],
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(4)
      end
    end

    context "and person 3" do
      let(:question_id) { "details_known_3" }
      let(:person_index) { 5 }

      before do
        allow(page).to receive(:id).and_return("person_3_known_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("details_known_3")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know the details for person 3?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Details known for person 3?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to be_nil
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          "depends_on" => [{ "details_known_3" => 1 }],
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(5)
      end
    end

    context "and person 4" do
      let(:question_id) { "details_known_4" }
      let(:person_index) { 6 }

      before do
        allow(page).to receive(:id).and_return("person_4_known_joint_purchase")
      end

      it "has the correct id" do
        expect(question.id).to eq("details_known_4")
      end

      it "has the correct header" do
        expect(question.header).to eq("Do you know the details for person 4?")
      end

      it "has the correct check_answer_label" do
        expect(question.check_answer_label).to eq("Details known for person 4?")
      end

      it "has correct conditional for" do
        expect(question.conditional_for).to be_nil
      end

      it "has the correct hidden_in_check_answers" do
        expect(question.hidden_in_check_answers).to eq(
          "depends_on" => [{ "details_known_4" => 1 }],
        )
      end

      it "has the correct check_answers_card_number" do
        expect(question.check_answers_card_number).to eq(6)
      end
    end
  end
end

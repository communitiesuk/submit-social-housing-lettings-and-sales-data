require "rails_helper"

RSpec.describe Form::Lettings::Questions::GenderDescription, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "gender_description1" }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 1 }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: current_collection_start_date) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct type" do
    expect(question.type).to eq("text")
  end

  context "when person 1" do
    let(:question_id) { "gender_description1" }
    let(:person_index) { 1 }
    let(:log) { build(:lettings_log, gender_same_as_sex1:) }

    it "has the correct id" do
      expect(question.id).to eq("gender_description1")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(1)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to be_nil
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(32)
    end

    context "and gender_same_as_sex for person 1 is 'Yes" do
      let(:gender_same_as_sex1) { 1 }

      it "is marked as derived" do
        expect(question.derived?(log)).to be true
      end
    end

    context "and gender_same_as_sex for person 1 is 'No" do
      let(:gender_same_as_sex1) { 2 }

      it "is not marked as derived" do
        expect(question.derived?(log)).to be false
      end
    end
  end

  context "when person 2" do
    let(:question_id) { "gender_description2" }
    let(:person_index) { 2 }

    it "has the correct id" do
      expect(question.id).to eq("gender_description2")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(2)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to be_nil
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(40)
    end
  end

  context "when person 3" do
    let(:question_id) { "gender_description3" }
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("gender_description3")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(3)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to be_nil
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(45)
    end
  end

  context "when person 4" do
    let(:question_id) { "gender_description4" }
    let(:person_index) { 4 }

    it "has the correct id" do
      expect(question.id).to eq("gender_description4")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(4)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to be_nil
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(50)
    end
  end

  context "when person 5" do
    let(:question_id) { "gender_description5" }
    let(:person_index) { 5 }

    it "has the correct id" do
      expect(question.id).to eq("gender_description5")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(5)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to be_nil
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(55)
    end
  end

  context "when person 6" do
    let(:question_id) { "gender_description6" }
    let(:person_index) { 6 }

    it "has the correct id" do
      expect(question.id).to eq("gender_description6")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(6)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to be_nil
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(60)
    end
  end

  context "when person 7" do
    let(:question_id) { "gender_description7" }
    let(:person_index) { 7 }

    it "has the correct id" do
      expect(question.id).to eq("gender_description7")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(7)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to be_nil
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(65)
    end
  end

  context "when person 8" do
    let(:question_id) { "gender_description8" }
    let(:person_index) { 8 }

    it "has the correct id" do
      expect(question.id).to eq("gender_description8")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(8)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to be_nil
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(70)
    end
  end
end

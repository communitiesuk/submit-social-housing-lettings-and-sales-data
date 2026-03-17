require "rails_helper"

RSpec.describe Form::Sales::Questions::GenderDescription, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 2 }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: current_collection_start_date, person_question_count: 4) }

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
    let(:person_index) { 1 }

    it "has the correct id" do
      expect(question.id).to eq("gender_description1")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(1)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to be_nil
    end

    context "when gender_same_as_sex1 is 'Yes'" do
      let(:log) { build(:sales_log, gender_same_as_sex1: 1) }

      it "is marked as derived" do
        expect(question.derived?(log)).to be true
      end
    end

    context "when gender_same_as_sex1 is 'No'" do
      let(:log) { build(:sales_log, gender_same_as_sex1: 2) }

      it "is not marked as derived" do
        expect(question.derived?(log)).to be false
      end
    end

    context "when gender_same_as_sex1 is 'Prefers not to say'" do
      let(:log) { build(:sales_log, gender_same_as_sex1: 3) }

      it "is marked as derived" do
        expect(question.derived?(log)).to be true
      end
    end
  end

  context "when person 2" do
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

    context "when gender_same_as_sex2 is 'Yes'" do
      let(:log) { build(:sales_log, gender_same_as_sex2: 1) }

      it "is marked as derived" do
        expect(question.derived?(log)).to be true
      end
    end

    context "when gender_same_as_sex2 is 'No'" do
      let(:log) { build(:sales_log, gender_same_as_sex2: 2) }

      it "is not marked as derived" do
        expect(question.derived?(log)).to be false
      end
    end
  end

  context "when person 3" do
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
  end

  context "when person 4" do
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
  end

  context "when person 5" do
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
  end

  context "when person 6" do
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
  end
end

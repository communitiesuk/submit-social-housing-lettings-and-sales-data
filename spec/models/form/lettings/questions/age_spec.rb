require "rails_helper"

RSpec.describe Form::Lettings::Questions::Age, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(nil, question_definition, page, person_index:) }

  let(:question_definition) { nil }
  let(:start_year_2026_or_later?) { false }
  let(:person_question_count) { 5 }
  let(:start_year) { current_collection_start_year }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: collection_start_date_for_year(start_year), start_year_2024_or_later?: true, start_year_2026_or_later?: start_year_2026_or_later?, person_question_count:))) }
  let(:person_index) { 2 }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct min" do
    expect(question.min).to eq(1)
  end

  it "has the correct max" do
    expect(question.max).to eq(120)
  end

  it "has the correct width" do
    expect(question.width).to eq(2)
  end

  context "with person 2" do
    it "has the correct id" do
      expect(question.id).to eq("age2")
    end

    it "has the correct inferred check answers value" do
      expect(question.inferred_check_answers_value).to eq([
        {
          "condition" => { "age2_known" => 1 },
          "value" => "Not known",
        },
      ])
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(2)
    end

    context "with year 2025", metadata: { year: 25 } do
      let(:start_year) { 2025 }
      let(:person_question_count) { 4 }

      it "has the correct question number" do
        expect(question.question_number).to eq(38)
      end
    end

    context "with year 2026", metadata: { year: 26 } do
      let(:start_year_2026_or_later?) { true }
      let(:start_year) { 2026 }
      let(:person_question_count) { 5 }

      it "has the correct question number" do
        expect(question.question_number).to eq(37)
      end
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("age3")
    end

    it "has the correct inferred check answers value" do
      expect(question.inferred_check_answers_value).to eq([
        {
          "condition" => { "age3_known" => 1 },
          "value" => "Not known",
        },
      ])
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(3)
    end

    context "with year 2025", metadata: { year: 25 } do
      let(:start_year) { 2025 }
      let(:person_question_count) { 4 }

      it "has the correct question number" do
        expect(question.question_number).to eq(42)
      end
    end

    context "with year 2026", metadata: { year: 26 } do
      let(:start_year_2026_or_later?) { true }
      let(:start_year) { 2026 }
      let(:person_question_count) { 5 }

      it "has the correct question number" do
        expect(question.question_number).to eq(42)
      end
    end
  end
end

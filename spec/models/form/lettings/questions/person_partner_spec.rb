require "rails_helper"

RSpec.describe Form::Lettings::Questions::PersonPartner, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(nil, question_definition, page, person_index:) }

  let(:question_definition) { nil }
  let(:year) { nil }
  let(:page) {
    instance_double(
      Form::Page,
      subsection: instance_double(
        Form::Subsection,
        form: instance_double(
          Form,
          start_date: year ? collection_start_date_for_year(year) : current_collection_start_date,
          start_year_2025_or_later?: year.nil? || year >= 2025,
          start_year_2026_or_later?: year.nil? || year >= 2026,
        )
      )
    )
  }
  let(:person_index) { 2 }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq("P" => { "value" => "Yes" },
                                          "X" => { "value" => "No" },
                                          "R" => { "value" => "Tenant prefers not to say" })
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

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(2)
    end

    context "with person 2 age < 16" do
      let(:log) { build(:lettings_log, age2: 10) }

      context "and in 2025", metadata: { year: 25 } do
        let(:year) { 2025 }

        it "is not marked as derived" do
          expect(question.derived?(log)).to be false
        end
      end

      context "and in 2026", metadata: { year: 26 } do
        let(:year) { 2026 }

        it "is marked as derived" do
          expect(question.derived?(log)).to be true
        end
      end
    end

    context "with person 2 age >= 16" do
      let(:log) { build(:lettings_log, age2: 20) }

      context "and in 2025", metadata: { year: 25 } do
        let(:year) { 2025 }

        it "is not marked as derived" do
          expect(question.derived?(log)).to be false
        end
      end

      context "and in 2026", metadata: { year: 26 } do
        let(:year) { 2026 }

        it "is not marked as derived" do
          expect(question.derived?(log)).to be false
        end
      end
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("relat3")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(3)
    end
  end
end

require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonWorkingSituation, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "ecstat2" }
  let(:question_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_2025_or_later?: false) }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: form)) }
  let(:person_index) { 2 }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Full-time - 30 hours or more" },
      "2" => { "value" => "Part-time - Less than 30 hours" },
      "3" => { "value" => "In government training into work" },
      "4" => { "value" => "Jobseeker" },
      "6" => { "value" => "Not seeking work" },
      "8" => { "value" => "Unable to work due to long term sick or disability" },
      "5" => { "value" => "Retired" },
      "0" => { "value" => "Other" },
      "10" => { "value" => "Person prefers not to say" },
      "7" => { "value" => "Full-time student" },
      "9" => { "value" => "Child under 16",
               "depends_on" =>
        [{ "saledate" => { "operator" => "<", "operand" => Time.zone.local(2024, 4, 1) } },
         { "age2_known" => 1 },
         { "age2_known" => nil },
         { "age2" => { "operator" => "<", "operand" => 16 } }] },
    })
  end

  context "with start year before 2025" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_2025_or_later?: false) }

    it "uses the old ordering for answer options" do
      expect(question.answer_options.keys).to eq(%w[1 2 3 4 6 8 5 0 10 7 9])
    end
  end

  context "with start year from 2025" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2025, 4, 1), start_year_2025_or_later?: true) }

    it "uses the new ordering for answer options" do
      expect(question.answer_options.keys).to eq(%w[1 2 3 4 5 6 7 8 9 0 10])
    end
  end

  context "when person 2" do
    let(:question_id) { "ecstat2" }
    let(:person_index) { 2 }

    it "has the correct id" do
      expect(question.id).to eq("ecstat2")
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

require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonAge, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "age3" }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_after_2024?: false))) }
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
    expect(question.min).to eq(0)
  end

  it "has the correct max" do
    expect(question.max).to eq(110)
  end

  it "has the correct width" do
    expect(question.width).to eq(3)
  end

  it "has the correct step" do
    expect(question.step).to be 1
  end

  context "with person 2" do
    let(:person_index) { 2 }
    let(:question_id) { "age2" }

    it "has the correct id" do
      expect(question.id).to eq("age2")
    end

    it "has the correct inferred check answers value" do
      expect(question.inferred_check_answers_value).to eq([{
        "condition" => { "age2_known" => 1 },
        "value" => "Not known",
      }])
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(2)
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }
    let(:question_id) { "age3" }

    it "has the correct id" do
      expect(question.id).to eq("age3")
    end

    it "has the correct inferred check answers value" do
      expect(question.inferred_check_answers_value).to eq([{
        "condition" => { "age3_known" => 1 },
        "value" => "Not known",
      }])
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(3)
    end
  end

  context "with person 4" do
    let(:person_index) { 4 }
    let(:question_id) { "age4" }

    it "has the correct id" do
      expect(question.id).to eq("age4")
    end

    it "has the correct inferred check answers value" do
      expect(question.inferred_check_answers_value).to eq([{
        "condition" => { "age4_known" => 1 },
        "value" => "Not known",
      }])
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(4)
    end
  end

  context "with person 5" do
    let(:person_index) { 5 }
    let(:question_id) { "age5" }

    it "has the correct id" do
      expect(question.id).to eq("age5")
    end

    it "has the correct inferred check answers value" do
      expect(question.inferred_check_answers_value).to eq([{
        "condition" => { "age5_known" => 1 },
        "value" => "Not known",
      }])
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(5)
    end
  end
end

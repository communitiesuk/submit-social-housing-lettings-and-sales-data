require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonGenderSameAsSex, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 2 }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2026, 4, 1)) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

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
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No, enter gender identity" },
      "divider" => { "value" => true },
      "3" => { "value" => "Person prefers not to say" },
    })
  end

  it "returns correct label_from_value for 'Prefers not to say'" do
    expect(question.label_from_value(3)).to eq("Prefers not to say")
  end

  context "when person 2" do
    let(:person_index) { 2 }

    it "has the correct id" do
      expect(question.id).to eq("gender_same_as_sex2")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(2)
    end

    it "has the correct conditional_for" do
      expect(question.conditional_for).to eq({ "gender_description2" => [2] })
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([{ "condition" => { "gender_same_as_sex2" => 2 }, "value" => "No" }])
    end
  end

  context "when person 3" do
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("gender_same_as_sex3")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(3)
    end

    it "has the correct conditional_for" do
      expect(question.conditional_for).to eq({ "gender_description3" => [2] })
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([{ "condition" => { "gender_same_as_sex3" => 2 }, "value" => "No" }])
    end
  end

  context "when person 4" do
    let(:person_index) { 4 }

    it "has the correct id" do
      expect(question.id).to eq("gender_same_as_sex4")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(4)
    end

    it "has the correct conditional_for" do
      expect(question.conditional_for).to eq({ "gender_description4" => [2] })
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([{ "condition" => { "gender_same_as_sex4" => 2 }, "value" => "No" }])
    end
  end

  context "when person 5" do
    let(:person_index) { 5 }

    it "has the correct id" do
      expect(question.id).to eq("gender_same_as_sex5")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(5)
    end

    it "has the correct conditional_for" do
      expect(question.conditional_for).to eq({ "gender_description5" => [2] })
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([{ "condition" => { "gender_same_as_sex5" => 2 }, "value" => "No" }])
    end
  end

  context "when person 6" do
    let(:person_index) { 6 }

    it "has the correct id" do
      expect(question.id).to eq("gender_same_as_sex6")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(6)
    end

    it "has the correct conditional_for" do
      expect(question.conditional_for).to eq({ "gender_description6" => [2] })
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([{ "condition" => { "gender_same_as_sex6" => 2 }, "value" => "No" }])
    end
  end
end

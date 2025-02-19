require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonGenderIdentity, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "sex2" }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 2 }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

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
      "F" => { "value" => "Female" },
      "M" => { "value" => "Male" },
      "X" => { "value" => "Non-binary" },
      "R" => { "value" => "Person prefers not to say" },
    })
  end

  context "when person 2" do
    let(:question_id) { "sex2" }
    let(:person_index) { 2 }

    it "has the correct id" do
      expect(question.id).to eq("sex2")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(2)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "sex2" => "R" }, "value" => "Prefers not to say" },
      ])
    end
  end

  context "when person 3" do
    let(:question_id) { "sex3" }
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("sex3")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(3)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "sex3" => "R" }, "value" => "Prefers not to say" },
      ])
    end
  end

  context "when person 4" do
    let(:question_id) { "sex4" }
    let(:person_index) { 4 }

    it "has the correct id" do
      expect(question.id).to eq("sex4")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(4)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "sex4" => "R" }, "value" => "Prefers not to say" },
      ])
    end
  end

  context "when person 5" do
    let(:question_id) { "sex5" }
    let(:person_index) { 5 }

    it "has the correct id" do
      expect(question.id).to eq("sex5")
    end

    it "has expected check answers card number" do
      expect(question.check_answers_card_number).to eq(5)
    end

    it "has the correct inferred_check_answers_value" do
      expect(question.inferred_check_answers_value).to eq([
        { "condition" => { "sex5" => "R" }, "value" => "Prefers not to say" },
      ])
    end
  end
end

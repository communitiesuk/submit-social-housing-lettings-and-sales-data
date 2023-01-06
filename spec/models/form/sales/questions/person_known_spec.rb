require "rails_helper"

RSpec.describe Form::Sales::Questions::PersonKnown, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, person_index:) }

  let(:question_id) { "details_known_1" }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 1 }

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

  it "has correct conditional for" do
    expect(question.conditional_for).to eq(nil)
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("")
  end

  context "with person 1" do
    let(:question_id) { "details_known_1" }
    let(:person_index) { 1 }

    it "has the correct id" do
      expect(question.id).to eq("details_known_1")
    end

    it "has the correct header" do
      expect(question.header).to eq("Do you know the details for person 1?")
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Details known for person 1?")
    end

    it "has the correct hidden_in_check_answers" do
      expect(question.hidden_in_check_answers).to eq(
        {
          "depends_on" => [
            {
              "details_known_1" => 1,
            },
          ],
        },
      )
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(3)
    end
  end
end

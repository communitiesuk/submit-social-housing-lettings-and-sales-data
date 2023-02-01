require "rails_helper"

RSpec.describe Form::Lettings::Questions::PersonWorkingSituation, type: :model do
  subject(:question) { described_class.new(nil, question_definition, page, person_index:) }

  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:person_index) { 2 }

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
    expect(question.answer_options).to eq("0" => { "value" => "Other" },
                                          "1" => { "value" => "Full-time – 30 hours or more" },
                                          "10" => { "value" => "Tenant prefers not to say" },
                                          "2" => { "value" => "Part-time – Less than 30 hours" },
                                          "3" => { "value" => "In government training into work, such as New Deal" },
                                          "4" => { "value" => "Jobseeker" },
                                          "5" => { "value" => "Retired" },
                                          "6" => { "value" => "Not seeking work" },
                                          "7" => { "value" => "Full-time student" },
                                          "8" => { "value" => "Unable to work because of long term sick or disability" },
                                          "9" => { "depends_on" => [{ "age2_known" => 1 }, { "age2" => { "operand" => 16, "operator" => "<" } }], "value" => "Child under 16" },
                                          "divider" => { "value" => true })
  end

  it "has the correct hint" do
    expect(question.hint_text).to eq("")
  end

  it "has correct conditional for" do
    expect(question.conditional_for).to be nil
  end

  it "has the correct hidden_in_check_answers" do
    expect(question.hidden_in_check_answers).to be nil
  end

  context "with person 2" do
    it "has the correct id" do
      expect(question.id).to eq("ecstat2")
    end

    it "has the correct header" do
      expect(question.header).to eq("Which of these best describes person 2’s working situation?")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(2)
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 2’s working situation")
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("ecstat3")
    end

    it "has the correct header" do
      expect(question.header).to eq("Which of these best describes person 3’s working situation?")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(3)
    end

    it "has the correct check_answer_label" do
      expect(question.check_answer_label).to eq("Person 3’s working situation")
    end
  end
end

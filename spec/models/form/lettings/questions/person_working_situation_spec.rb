require "rails_helper"

RSpec.describe Form::Lettings::Questions::PersonWorkingSituation, type: :model do
  subject(:question) { described_class.new(nil, question_definition, page, person_index:) }

  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2025, 4, 4)))) }
  let(:person_index) { 2 }

  before do
    allow(page.subsection.form).to receive(:start_year_2025_or_later?).and_return(true)
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
    expect(question.answer_options).to eq("0" => { "value" => "Other" },
                                          "1" => { "value" => "Full-time – 30 hours or more per week" },
                                          "10" => { "value" => "Person prefers not to say" },
                                          "2" => { "value" => "Part-time – Less than 30 hours per week" },
                                          "3" => { "value" => "In government training into work" },
                                          "4" => { "value" => "Jobseeker" },
                                          "5" => { "value" => "Retired" },
                                          "6" => { "value" => "Not seeking work" },
                                          "7" => { "value" => "Full-time student" },
                                          "8" => { "value" => "Unable to work because of long-term sickness or disability" },
                                          "9" => {
                                            "depends_on" => [
                                              { "age2_known" => 1 },
                                              { "age2_known" => nil },
                                              { "age2" => { "operand" => 16, "operator" => "<" } },
                                            ],
                                            "value" => "Child under 16",
                                          },
                                          "divider" => { "value" => true })
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

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(2)
    end
  end

  context "with person 3" do
    let(:person_index) { 3 }

    it "has the correct id" do
      expect(question.id).to eq("ecstat3")
    end

    it "has the correct check_answers_card_number" do
      expect(question.check_answers_card_number).to eq(3)
    end
  end
end

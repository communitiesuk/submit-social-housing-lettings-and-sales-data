require "rails_helper"

RSpec.describe Form::Sales::Questions::Buyer2WorkingSituation, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_2025_or_later?: false) }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form:)) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("ecstat2")
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
      "10" => { "value" => "Buyer prefers not to say" },
      "7" => { "value" => "Full-time student" },
      "9" => { "value" => "Child under 16" },
    })
  end

  it "has the correct displayed_answer_options" do
    expect(question.displayed_answer_options(nil)).to eq({
      "1" => { "value" => "Full-time - 30 hours or more" },
      "2" => { "value" => "Part-time - Less than 30 hours" },
      "3" => { "value" => "In government training into work" },
      "4" => { "value" => "Jobseeker" },
      "6" => { "value" => "Not seeking work" },
      "8" => { "value" => "Unable to work due to long term sick or disability" },
      "5" => { "value" => "Retired" },
      "0" => { "value" => "Other" },
      "10" => { "value" => "Buyer prefers not to say" },
      "7" => { "value" => "Full-time student" },
    })
  end

  context "with start year before 2025" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2024, 4, 1), start_year_2025_or_later?: false) }

    it "uses the old ordering for answer options" do
      expect(question.answer_options.keys).to eq(%w[1 2 3 4 6 8 5 0 10 7 9])
    end

    it "uses the old ordering for displayed answer options" do
      expect(question.displayed_answer_options(nil).keys).to eq(%w[1 2 3 4 6 8 5 0 10 7])
    end
  end

  context "with start year from 2025" do
    let(:form) { instance_double(Form, start_date: Time.zone.local(2025, 4, 1), start_year_2025_or_later?: true) }

    it "uses the new ordering for answer options" do
      expect(question.answer_options.keys).to eq(%w[1 2 3 4 5 6 7 8 9 0 10])
    end

    it "uses the new ordering for displayed answer options" do
      expect(question.displayed_answer_options(nil).keys).to eq(%w[1 2 3 4 5 6 7 8 0 10])
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "1" => { "value" => "Full-time – 30 hours or more per week" },
        "2" => { "value" => "Part-time – Less than 30 hours per week" },
        "3" => { "value" => "In government training into work" },
        "4" => { "value" => "Jobseeker" },
        "6" => { "value" => "Not seeking work" },
        "8" => { "value" => "Unable to work because of long-term sickness or disability" },
        "5" => { "value" => "Retired" },
        "0" => { "value" => "Other" },
        "10" => { "value" => "Buyer prefers not to say" },
        "7" => { "value" => "Full-time student" },
        "9" => { "value" => "Child under 16" },
      })
    end

    it "has the correct displayed_answer_options" do
      expect(question.displayed_answer_options(nil)).to eq({
        "1" => { "value" => "Full-time – 30 hours or more per week" },
        "2" => { "value" => "Part-time – Less than 30 hours per week" },
        "3" => { "value" => "In government training into work" },
        "4" => { "value" => "Jobseeker" },
        "6" => { "value" => "Not seeking work" },
        "8" => { "value" => "Unable to work because of long-term sickness or disability" },
        "5" => { "value" => "Retired" },
        "0" => { "value" => "Other" },
        "10" => { "value" => "Buyer prefers not to say" },
        "7" => { "value" => "Full-time student" },
      })
    end
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(2)
  end

  it "has the correct inferred_check_answers_value" do
    expect(question.inferred_check_answers_value).to eq([
      { "condition" => { "ecstat2" => 10 }, "value" => "Prefers not to say" },
    ])
  end
end

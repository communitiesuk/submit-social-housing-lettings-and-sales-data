require "rails_helper"

RSpec.describe Form::Lettings::Questions::Layear, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form) }

  before do
    allow(form).to receive(:start_year_after_2024?).and_return(false)
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("layear")
  end

  it "has the correct header" do
    expect(question.header).to eq("How long has the household continuously lived in the local authority area of the new letting?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Length of time in local authority area")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?).to be false
  end

  context "with 2023/24 form" do
    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "1" => { "value" => "Just moved to local authority area" },
        "2" => { "value" => "Less than 1 year" },
        "7" => { "value" => "1 year but under 2 years" },
        "8" => { "value" => "2 years but under 3 years" },
        "9" => { "value" => "3 years but under 4 years" },
        "10" => { "value" => "4 years but under 5 years" },
        "5" => { "value" => "5 years or more" },
        "divider" => { "value" => true },
        "6" => { "value" => "Don’t know" },
      })
    end
  end

  context "with 2024/25 form" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "1" => { "value" => "Just moved to local authority area with this new let" },
        "2" => { "value" => "Less than 1 year" },
        "7" => { "value" => "1 year but under 2 years" },
        "8" => { "value" => "2 years but under 3 years" },
        "9" => { "value" => "3 years but under 4 years" },
        "10" => { "value" => "4 years but under 5 years" },
        "11" => { "value" => "5 years but under 10 years" },
        "12" => { "value" => "10 years or more" },
        "divider" => { "value" => true },
        "6" => { "value" => "Don’t know" },
      })
    end
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(0)
  end
end
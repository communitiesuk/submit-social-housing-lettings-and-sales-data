require "rails_helper"

RSpec.describe Form::Lettings::Questions::Hb, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  before do
    allow(form).to receive(:start_year_after_2024?).and_return(false)
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("hb")
  end

  it "has the correct header" do
    expect(question.header).to eq("Is the household likely to be receiving any of these housing-related benefits?")
  end

  it "has the correct check_answer_label" do
    expect(question.check_answer_label).to eq("Housing-related benefits received")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "Housing benefit" },
      "6" => { "value" => "Universal Credit housing element" },
      "9" => { "value" => "Neither" },
      "divider" => { "value" => true },
      "3" => { "value" => "Don’t know" },
      "10" => { "value" => "Tenant prefers not to say" },

    })
  end

  context "with 2023/24 form" do
    it "has the correct hint" do
      expect(question.hint_text).to eq("")
    end
  end

  context "with 2024/25 form" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "has the correct hint" do
      expect(question.hint_text).to eq("This is about when the tenant is in their new let. If they are unsure about the situation for their new let and their financial and working situation hasn’t changed significantly, answer based on what housing-related benefits they currently receive.")
    end
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(0)
  end
end

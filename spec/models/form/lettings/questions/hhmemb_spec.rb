require "rails_helper"

RSpec.describe Form::Lettings::Questions::Hhmemb, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(nil, question_definition, page) }

  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page) }
  let(:subsection) { instance_double(Form::Subsection) }
  let(:start_year_2026_or_later?) { false }
  let(:form) { instance_double(Form, start_date: current_collection_start_date, start_year_2026_or_later?: start_year_2026_or_later?) }

  before do
    allow(page).to receive(:subsection).and_return(subsection)
    allow(subsection).to receive(:form).and_return(form)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct id" do
    expect(question.id).to eq("hhmemb")
  end

  it "has the correct check_answers_card_number" do
    expect(question.check_answers_card_number).to eq(0)
  end

  context "when in 2025", { year: 25 } do
    it "does not have check answers card title" do
      expect(question.check_answers_card_title).to be_nil
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(30)
    end
  end

  context "when in 2026", { year: 26 } do
    let(:start_year_2026_or_later?) { true }

    it "has correct check answers card title" do
      expect(question.check_answers_card_title).to eq("Household")
    end

    it "has the correct question number" do
      expect(question.question_number).to eq(30)
    end
  end
end

require "rails_helper"

RSpec.describe Form::Sales::Questions::BuyerStillServing, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:start_year_2026_or_later?) { true }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: current_collection_start_date, start_year_2026_or_later?: start_year_2026_or_later?))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("hhregresstill")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  context "when 2025", metadata: { year: 25 } do
    let(:start_year_2026_or_later?) { false }

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "4" => { "value" => "Yes" },
        "5" => { "value" => "No" },
        "6" => { "value" => "Buyer prefers not to say" },
        "divider" => { "value" => true },
        "7" => { "value" => "Don’t know" },
      })
    end
  end

  context "when 2026", metadata: { year: 26 } do
    let(:start_year_2026_or_later?) { true }

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "4" => { "value" => "Yes" },
        "5" => { "value" => "No - they left up to and including 2 years ago" },
        "6" => { "value" => "No - they left more than 2 years ago" },
        "divider" => { "value" => true },
        "7" => { "value" => "Don’t know" },
      })
    end
  end
end

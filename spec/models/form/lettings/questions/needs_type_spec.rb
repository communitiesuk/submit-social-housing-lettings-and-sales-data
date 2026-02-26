require "rails_helper"

RSpec.describe Form::Lettings::Questions::NeedsType, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:start_year_2026_or_later?) { false }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1), start_year_2026_or_later?: start_year_2026_or_later?))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("needstype")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question).not_to be_derived(nil)
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "General needs" },
      "2" => { "value" => "Supported housing" },
    })
  end

  context "when 2025 logs", metadata: { year: 25 } do
    it "has no top guidance partial" do
      expect(question.top_guidance_partial).to be_nil
    end
  end

  context "when 2026 logs", metadata: { year: 26 } do
    let(:start_year_2026_or_later?) { true }

    it "has correct guidance partial" do
      expect(question.top_guidance_partial).to eq("needs_type")
    end
  end
end

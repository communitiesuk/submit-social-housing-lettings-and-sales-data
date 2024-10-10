require "rails_helper"

RSpec.describe Form::Sales::Questions::SharedOwnershipType, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:start_date) { current_collection_start_date }
  let(:form) { instance_double(Form, start_date:) }
  let(:subsection) { instance_double(Form::Subsection, form:) }
  let(:page) { instance_double(Form::Page, subsection:) }

  before do
    allow(form).to receive(:start_year_after_2024?).and_return(true)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("type")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  context "when form start date is 2023/24" do
    let(:start_date) { Time.zone.local(2023, 4, 2) }

    before do
      allow(form).to receive(:start_year_after_2024?).and_return(false)
    end

    it "has the correct answer_options" do
      expect(question.answer_options).to eq({
        "2" => { "value" => "Shared Ownership (old model lease)" },
        "30" => { "value" => "Shared Ownership (new model lease)" },
        "18" => { "value" => "Social HomeBuy — shared ownership purchase" },
        "16" => { "value" => "Home Ownership for people with Long-Term Disabilities (HOLD)" },
        "24" => { "value" => "Older Persons Shared Ownership" },
        "28" => { "value" => "Rent to Buy — Shared Ownership" },
        "31" => { "value" => "Right to Shared Ownership (RtSO)" },
        "32" => { "value" => "London Living Rent — Shared Ownership" },
      })
    end

    it "shows shows correct top_guidance_partial" do
      expect(question.top_guidance_partial).to eq("shared_ownership_type_definitions")
    end
  end

  context "when form start date is on or after 2024/25" do
    before do
      allow(form).to receive(:start_year_after_2024?).and_return(true)
    end

    it "shows shows correct top_guidance_partial" do
      expect(question.top_guidance_partial).to eq("shared_ownership_type_definitions_2024")
    end
  end
end

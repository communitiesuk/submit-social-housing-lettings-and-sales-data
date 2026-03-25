require "rails_helper"

RSpec.describe Form::Sales::Questions::Value, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:start_year) { current_collection_start_year }
  let(:start_year_2026_or_later?) { false }
  let(:page) { instance_double(Form::Page, id: "value_shared_ownership", subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: collection_start_date_for_year(start_year), start_year_2026_or_later?: start_year_2026_or_later?), id: "shared_ownership")) }

  before do
    allow(page.subsection.form).to receive(:start_year_2025_or_later?).and_return(false)
  end

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("value")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has correct width" do
    expect(question.width).to eq(5)
  end

  it "has correct prefix" do
    expect(question.prefix).to eq("£")
  end

  context "with year 2025", metadata: { year: 25 } do
    let(:start_year) { 2025 }

    it "has correct min" do
      expect(question.min).to eq(0)
    end
  end

  context "with year 2026", metadata: { year: 26 } do
    let(:start_year) { 2026 }
    let(:start_year_2026_or_later?) { true }

    it "has correct min" do
      expect(question.min).to eq(15_000)
    end
  end

  context "with year 2026 and staircasing subsection", metadata: { year: 26 } do
    let(:start_year) { 2026 }
    let(:start_year_2026_or_later?) { true }
    let(:page) { instance_double(Form::Page, id: "value_shared_ownership_staircase", subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: collection_start_date_for_year(start_year), start_year_2026_or_later?: start_year_2026_or_later?), id: "shared_ownership_staircasing_transaction")) }

    before do
      allow(page.subsection.form).to receive(:start_year_2025_or_later?).and_return(true)
    end

    it "has correct min" do
      expect(question.min).to eq(0)
    end
  end
end

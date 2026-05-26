require "rails_helper"

RSpec.describe Form::Sales::Questions::MonthlyRentBeforeStaircasing, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:start_year_2025_or_later?) { true }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: current_collection_start_date, start_year_2025_or_later?: start_year_2025_or_later?))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("mrentprestaircasing")
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

  it "has correct min" do
    expect(question.min).to eq(0)
  end

  it "has correct max" do
    expect(question.max).to eq(9_999)
  end
end

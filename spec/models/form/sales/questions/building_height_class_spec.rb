require "rails_helper"

RSpec.describe Form::Sales::Questions::BuildingHeightClass, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:start_date) { collection_start_date_for_year(2026) }
  let(:form) { instance_double(Form, start_date:) }
  let(:subsection) { instance_double(Form::Subsection, form:) }
  let(:page) { instance_double(Form::Page, subsection:) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("buildheightclass")
  end

  it "has the correct type" do
    expect(question.type).to eq("radio")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct answer_options" do
    expect(question.answer_options).to eq({
      "1" => { "value" => "High-rise" },
      "2" => { "value" => "Low-rise" },
      "3" => { "value" => "Don't know" },
    })
  end

  it "has the correct question_number" do
    expect(question.question_number).to eq(17)
  end
end

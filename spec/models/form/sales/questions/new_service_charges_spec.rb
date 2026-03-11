require "rails_helper"

RSpec.describe Form::Sales::Questions::NewServiceCharges, type: :model do
  include CollectionTimeHelper

  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection, id: "shared_ownership_staircasing_transaction", form: instance_double(Form, start_date:, start_year_2026_or_later?: true)) }
  let(:page) { instance_double(Form::Page, subsection:) }
  let(:start_date) { collection_start_date_for_year(2026) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("newservicecharges")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question.derived?(nil)).to be false
  end

  it "has the correct width" do
    expect(question.width).to be 5
  end

  it "has the correct min" do
    expect(question.min).to be 0
  end

  it "has the correct max" do
    expect(question.max).to be 9999.99
  end

  it "has the correct step" do
    expect(question.step).to be 0.01
  end

  it "has the correct prefix" do
    expect(question.prefix).to eq("£")
  end

  it "has the correct question number" do
    expect(question.question_number).to eq(111)
  end
end

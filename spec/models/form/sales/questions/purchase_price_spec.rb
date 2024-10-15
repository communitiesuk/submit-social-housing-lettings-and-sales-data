require "rails_helper"

RSpec.describe Form::Sales::Questions::PurchasePrice, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 1) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

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

  it "has the correct question_number" do
    expect(question.question_number).to be_nil
  end

  context "when discounted ownership scheme" do
    subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 2) }

    it "has the correct question_number" do
      expect(question.question_number).to eq(100)
    end
  end

  context "when outright sale" do
    subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 3) }

    it "has the correct question_number" do
      expect(question.question_number).to eq(110)
    end
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
end

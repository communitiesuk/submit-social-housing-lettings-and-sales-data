require "rails_helper"

RSpec.describe Form::Sales::Questions::MortgageLength, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 1) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("mortlen")
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

  it "has correct min" do
    expect(question.min).to eq(0)
  end

  it "has correct max" do
    expect(question.max).to eq(60)
  end

  context "when 1 year" do
    let(:sales_log) { FactoryBot.build(:sales_log, mortlen: 1) }

    it "has correct suffix" do
      expect(question.suffix_label(sales_log)).to eq(" year")
    end
  end

  context "when multiple years" do
    let(:sales_log) { FactoryBot.build(:sales_log, mortlen: 5) }

    it "has correct suffix" do
      expect(question.suffix_label(sales_log)).to eq(" years")
    end
  end
end

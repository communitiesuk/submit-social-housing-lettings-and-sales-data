require "rails_helper"

RSpec.describe Form::Sales::Questions::MortgageAmount, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page, ownershipsch: 1) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to be(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("mortgage")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  it "is not marked as derived" do
    expect(question).not_to be_derived(nil)
  end

  it "has correct width" do
    expect(question.width).to be(5)
  end

  it "has correct prefix" do
    expect(question.prefix).to eq("£")
  end

  it "has correct min" do
    expect(question.min).to be(1)
  end

  context "when the mortgage is not used" do
    let(:log) { build(:sales_log, :completed, mortgageused: 2, deposit: nil) }

    it "is marked as derived" do
      expect(question).to be_derived(log)
    end
  end

  context "when the mortgage is used" do
    let(:log) { build(:sales_log, :completed, mortgageused: 1) }

    it "is marked as derived" do
      expect(question).not_to be_derived(log)
    end
  end
end

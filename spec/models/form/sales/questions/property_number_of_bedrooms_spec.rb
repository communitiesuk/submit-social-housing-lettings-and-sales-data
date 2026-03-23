require "rails_helper"

RSpec.describe Form::Sales::Questions::PropertyNumberOfBedrooms, type: :model do
  subject(:question) { described_class.new(question_id, question_definition, page) }

  let(:question_id) { nil }
  let(:question_definition) { nil }
  let(:page) { instance_double(Form::Page, subsection: instance_double(Form::Subsection, form: instance_double(Form, start_date: Time.zone.local(2023, 4, 1)))) }

  it "has correct page" do
    expect(question.page).to eq(page)
  end

  it "has the correct id" do
    expect(question.id).to eq("beds")
  end

  it "has the correct type" do
    expect(question.type).to eq("numeric")
  end

  describe "#derived?" do
    context "when the log is a bedsit" do
      let(:log) { build(:sales_log, proptype: 2) }

      it "is marked as derived" do
        expect(question.derived?(log)).to be true
      end
    end

    context "when the log is not a bedsit" do
      let(:log) { build(:sales_log, proptype: 1) }

      it "is not marked as derived" do
        expect(question.derived?(log)).to be false
      end
    end
  end

  it "has the correct min" do
    expect(question.min).to eq(1)
  end

  it "has the correct max" do
    expect(question.max).to eq(9)
  end
end

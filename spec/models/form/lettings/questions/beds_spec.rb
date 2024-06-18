require "rails_helper"

RSpec.describe Form::Lettings::Questions::Beds, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page, subsection:) }
  let(:subsection) { instance_double(Form::Subsection, form:) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

  describe "the hint text" do
    context "when the start date is before 24/25" do
      before do
        allow(form).to receive(:start_year_after_2024?).and_return false
      end

      it "has the correct hint_text" do
        expect(question.hint_text).to eq("If shared accommodation, enter the number of bedrooms occupied by this household. A bedsit has 1 bedroom.")
      end
    end

    context "when the start date is 24/25 or after" do
      before do
        allow(form).to receive(:start_year_after_2024?).and_return true
      end

      it "has the correct hint_text" do
        expect(question.hint_text).to eq("If shared accommodation, enter the number of bedrooms occupied by this household.")
      end
    end
  end

  describe "whether the field is derived" do
    context "when the log is a bedsit" do
      let(:log) { build(:lettings_log, unittype_gn: 2) }

      it "is not marked as derived" do
        expect(question.derived?(log)).to be true
      end
    end

    context "when the log is not a bedsit" do
      let(:log) { build(:lettings_log, unittype_gn: 9) }

      it "is not marked as derived" do
        expect(question.derived?(log)).to be false
      end
    end
  end
end

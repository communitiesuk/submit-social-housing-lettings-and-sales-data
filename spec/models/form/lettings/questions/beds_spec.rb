require "rails_helper"

RSpec.describe Form::Lettings::Questions::Beds, type: :model do
  subject(:question) { described_class.new(nil, nil, page) }

  let(:page) { instance_double(Form::Page, subsection:) }
  let(:subsection) { instance_double(Form::Subsection, form:) }
  let(:form) { instance_double(Form, start_date: Time.zone.local(2023, 4, 1)) }

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

require "rails_helper"

RSpec.describe Form::Lettings::Pages::Outstanding, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { nil }
  let(:page_definition) { nil }
  let(:form) { Form.new(nil, 2024, [], "lettings") }
  let(:subsection) { instance_double(Form::Subsection, enabled?: true, form:, depends_on: nil) }

  describe "#routed_to?" do
    let(:log) { create(:lettings_log) }

    context "when hb is 1 and household_charge is 0" do
      let(:log) { build(:lettings_log, hb: 1, household_charge: 0) }

      it "is routed to" do
        expect(page.routed_to?(log, nil)).to eq(true)
      end
    end

    context "when hb is 6 and household_charge is 0" do
      let(:log) { build(:lettings_log, hb: 6, household_charge: 0) }

      it "is routed to" do
        expect(page.routed_to?(log, nil)).to eq(true)
      end
    end

    context "when hb is 1 and household_charge is nil" do
      let(:log) { build(:lettings_log, hb: 1, household_charge: nil) }

      it "is routed to" do
        expect(page.routed_to?(log, nil)).to eq(true)
      end
    end

    context "when hb is 6 and household_charge is nil" do
      let(:log) { build(:lettings_log, hb: 6, household_charge: nil) }

      it "is routed to" do
        expect(page.routed_to?(log, nil)).to eq(true)
      end
    end

    context "when hb is not 1 or 6" do
      let(:log) { build(:lettings_log, hb: 2, household_charge: nil) }

      it "is routed to" do
        expect(page.routed_to?(log, nil)).to eq(false)
      end
    end

    context "when household_charge is not nil or 0" do
      let(:log) { build(:lettings_log, hb: 6, household_charge: 1) }

      it "is not routed to" do
        expect(page.routed_to?(log, nil)).to eq(false)
      end
    end
  end
end

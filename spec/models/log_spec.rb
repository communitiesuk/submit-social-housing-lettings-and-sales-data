require "rails_helper"

RSpec.describe Log, type: :model do
  it "has two child log classes" do
    expect(SalesLog).to be < described_class
    expect(LettingsLog).to be < described_class
  end

  describe "#calculate_status" do
    it "returns the correct status for a completed sales log" do
      complete_sales_log = create(:sales_log, :completed, status: nil)
      expect(complete_sales_log.calculate_status).to eq "completed"
    end

    it "returns the correct status for an in progress sales log" do
      in_progress_sales_log = create(:sales_log, :in_progress, status: nil)
      expect(in_progress_sales_log.calculate_status).to eq "in_progress"
    end

    it "returns the correct status for a completed lettings log" do
      complete_lettings_log = create(:lettings_log, :completed, status: nil)
      expect(complete_lettings_log.calculate_status).to eq "completed"
    end

    it "returns the correct status for an in progress lettings log" do
      in_progress_lettings_log = create(:lettings_log, :in_progress, status: nil)
      expect(in_progress_lettings_log.calculate_status).to eq "in_progress"
    end
  end

  describe "#blank_invalid_non_setup_fields!" do
    context "when a setup field is invalid for a lettings log" do
      subject(:model) { build(:lettings_log, needstype: 404) }

      it "does not blank it" do
        model.valid?
        expect { model.blank_invalid_non_setup_fields! }.not_to change(model, :needstype)
      end
    end

    context "when a setup field is invalid for a sales log" do
      subject(:model) { build(:sales_log, companybuy: 404) }

      it "does not blank it" do
        model.valid?
        expect { model.blank_invalid_non_setup_fields! }.not_to change(model, :companybuy)
      end
    end

    context "when a non setup field is invalid for a lettings log" do
      subject(:model) { build(:lettings_log, :completed, offered: 234) }

      it "blanks it" do
        model.valid?
        model.blank_invalid_non_setup_fields!
        expect(model.offered).to be_nil
      end
    end

    context "when a non setup field is invalid for a sales log" do
      subject(:model) { build(:sales_log, :completed, age1: 10) }

      it "blanks it" do
        model.valid?
        model.blank_invalid_non_setup_fields!
        expect(model.age1).to be_nil
      end
    end

    context "when prevloc is invalid for a lettings log" do
      subject(:model) { build(:lettings_log, :completed, previous_la_known: 1, prevloc: nil) }

      it "blanks previous_la_known" do
        model.valid?
        model.blank_invalid_non_setup_fields!
        expect(model.previous_la_known).to be_nil
      end
    end
  end
end

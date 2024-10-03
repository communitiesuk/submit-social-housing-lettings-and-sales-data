require "rails_helper"

RSpec.describe SchemeDeactivationPeriod do
  let(:validator) { SchemeDeactivationPeriodValidator.new }
  let(:previous_collection_start_date) { Time.zone.local(2022, 4, 1) }
  let(:current_collection_start_date) { Time.zone.local(2023, 4, 1) }
  let(:scheme) { FactoryBot.create(:scheme, created_at: previous_collection_start_date - 2.years) }
  let(:record) { FactoryBot.create(:scheme_deactivation_period, deactivation_date: current_collection_start_date, scheme:) }

  describe "#validate" do
    before do
      allow(FormHandler.instance).to receive(:previous_collection_start_date).and_return(previous_collection_start_date)
      allow(FormHandler.instance).to receive(:current_collection_start_date).and_return(current_collection_start_date)
    end

    context "when not in a crossover period" do
      before do
        allow(FormHandler.instance).to receive(:in_edit_crossover_period?).and_return(false)
      end

      context "with a deactivation date before the current collection period" do
        it "adds an error" do
          record.deactivation_date = current_collection_start_date - 1.year
          scheme.scheme_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to include("The date must be on or after the 1 April 2023.")
        end
      end

      context "with a deactivation date in the current collection period" do
        it "does not add an error" do
          record.deactivation_date = current_collection_start_date + 1.day
          scheme.scheme_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to be_empty
        end
      end
    end

    context "when in a crossover period" do
      before do
        allow(FormHandler.instance).to receive(:in_edit_crossover_period?).and_return(true)
      end

      context "with a deactivation date before the previous collection period" do
        it "does not add an error" do
          record.deactivation_date = previous_collection_start_date - 2.years
          scheme.scheme_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to include("The date must be on or after the 1 April 2022.")
        end
      end

      context "with a deactivation date in the previous collection period" do
        it "does not add an error" do
          record.deactivation_date = previous_collection_start_date + 1.year
          scheme.scheme_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to be_empty
        end
      end

      context "with a deactivation date in the current collection period" do
        it "does not add an error" do
          record.deactivation_date = current_collection_start_date + 1.day
          scheme.scheme_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to be_empty
        end
      end
    end
  end
end

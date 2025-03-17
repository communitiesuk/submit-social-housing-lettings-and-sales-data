require "rails_helper"

RSpec.describe SchemeDeactivationPeriod do
  let(:validator) { SchemeDeactivationPeriodValidator.new }
  let(:previous_collection_start_date) { Time.zone.local(2022, 4, 1) }
  let(:current_collection_start_date) { Time.zone.local(2023, 4, 1) }

  describe "#validate" do
    before do
      allow(FormHandler.instance).to receive(:previous_collection_start_date).and_return(previous_collection_start_date)
      allow(FormHandler.instance).to receive(:current_collection_start_date).and_return(current_collection_start_date)
    end

    context "when not in a crossover period" do
      let(:scheme) { FactoryBot.create(:scheme, created_at: previous_collection_start_date - 2.years) }
      let(:record) { FactoryBot.create(:scheme_deactivation_period, deactivation_date: current_collection_start_date, scheme:) }

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
      let(:scheme) { FactoryBot.create(:scheme, created_at: previous_collection_start_date - 2.years) }
      let(:record) { FactoryBot.create(:scheme_deactivation_period, deactivation_date: current_collection_start_date, scheme:) }

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

    context "when there is an open deactivation period less than six months in the future" do # validate_reactivation
      let!(:scheme) { FactoryBot.build(:scheme, created_at: previous_collection_start_date - 2.years) }

      before do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.now + 5.months, scheme:)
      end

      context "when reactivation date is nil" do
        let(:record) { FactoryBot.build(:scheme_deactivation_period, deactivation_date: Time.zone.now, scheme:) }

        it "adds an error" do
          validator.validate(record)
          expect(record.errors.count).to eq(1)
          expect(record.errors[:reactivation_date_type]).to include("Select one of the options.")
        end
      end

      context "when reactivation date is present" do
        context "when reactivation date is before the existing period's start" do
          let(:record) { FactoryBot.build(:scheme_deactivation_period, deactivation_date: Time.zone.now + 3.months, reactivation_date: Time.zone.now + 4.months, scheme:) }

          it "adds an error" do
            validator.validate(record)
            expect(record.errors[:reactivation_date].count).to eq(1)
            expect(record.errors[:reactivation_date][0]).to match("The reactivation date must be on or after deactivation date.")
          end
        end

        context "when reactivation date is after the existing period's start" do
          let(:record) { FactoryBot.build(:scheme_deactivation_period, deactivation_date: Time.zone.now + 3.months, reactivation_date: Time.zone.now + 6.months, scheme:) }

          it "does not add an error" do
            validator.validate(record)
            expect(record.errors).to be_empty
          end
        end
      end
    end

    context "when there is not an open deactivation period within six months" do # validate_deactivation
      let!(:scheme) { FactoryBot.create(:scheme, created_at: previous_collection_start_date - 2.years) }
      before do
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.now + 7.months, reactivation_date: Time.zone.now + 8.months, scheme:)
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.now + 1.month, reactivation_date: Time.zone.now + 2.months, scheme:)
        FactoryBot.create(:scheme_deactivation_period, deactivation_date: Time.zone.now + 9.months, scheme:)
      end

      context "when reactivation date is nil" do
        let(:record) { FactoryBot.build(:scheme_deactivation_period, deactivation_date: Time.zone.now, scheme:) }

        it "does not add an error" do
          validator.validate(record)
          expect(record.errors).to be_empty
        end
      end

      context "when reactivation date is present" do
        context "when deactivation date is less than six months in the future" do
          let(:record) { FactoryBot.build(:scheme_deactivation_period, deactivation_date: Time.zone.now + 3.months, reactivation_date: Time.zone.now + 4.months, scheme:) }

          it "does not add an error" do
            validator.validate(record)
            expect(record.errors).to be_empty
          end
        end

        context "when deactivation date is more than six months in the future" do
          let(:record) { FactoryBot.build(:scheme_deactivation_period, deactivation_date: Time.zone.now + 9.months, reactivation_date: Time.zone.now + 10.months, scheme:) }

          it "does not add an error" do
            validator.validate(record)
            expect(record.errors).to be_empty
          end
        end
      end
    end
  end
end

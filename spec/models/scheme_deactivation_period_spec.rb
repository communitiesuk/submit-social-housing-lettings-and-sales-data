require "rails_helper"

RSpec.describe SchemeDeactivationPeriod do
  let(:validator) { SchemeDeactivationPeriodValidator.new }
  let(:scheme) { FactoryBot.create(:scheme, created_at: now - 2.years) }
  let(:record) { FactoryBot.create(:scheme_deactivation_period, deactivation_date: now, scheme:) }

  describe "#validate" do
    around do |example|
      Timecop.freeze(now) do
        example.run
      end
    end

    context "when not in a crossover period" do
      let(:now) { Time.utc(2023, 3, 1) }

      context "with a deactivation date before the current collection period" do
        it "adds an error" do
          record.deactivation_date = now - 1.year
          scheme.scheme_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to include("The date must be on or after the 1 April 2022")
        end
      end

      context "with a deactivation date in the current collection period" do
        it "does not add an error" do
          record.deactivation_date = now - 1.day
          scheme.scheme_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to be_empty
        end
      end
    end

    context "when in a crossover period" do
      let(:now) { Time.utc(2023, 5, 1) }

      context "with a deactivation date before the previous collection period" do
        it "does not add an error" do
          record.deactivation_date = now - 2.years
          scheme.scheme_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to include("The date must be on or after the 1 April 2022")
        end
      end

      context "with a deactivation date in the previous collection period" do
        it "does not add an error" do
          record.deactivation_date = now - 1.year
          scheme.scheme_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to be_empty
        end
      end

      context "with a deactivation date in the current collection period" do
        it "does not add an error" do
          record.deactivation_date = now - 1.day
          scheme.scheme_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to be_empty
        end
      end

      context "but the scheme was created in the current collection period" do
        let(:scheme) { FactoryBot.create(:scheme, created_at: now - 2.days) }

        context "with a deactivation date in the previous collection period" do
          it "adds an error" do
            record.deactivation_date = now - 1.year
            scheme.scheme_deactivation_periods.clear
            validator.validate(record)
            expect(record.errors[:deactivation_date]).to include "The scheme cannot be deactivated before 1 April 2023, the start of the collection year when it was created"
          end
        end
      end
    end
  end
end
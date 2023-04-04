require "rails_helper"

RSpec.describe LocationDeactivationPeriod do
  let(:validator) { LocationDeactivationPeriodValidator.new }
  let(:location) { FactoryBot.create(:location, startdate: now - 2.years) }
  let(:record) { FactoryBot.create(:location_deactivation_period, deactivation_date: now, location:) }

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
          location.location_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to include "The date must be on or after the 1 April 2022"
        end
      end

      context "with a deactivation date in the current collection period" do
        it "does not add an error" do
          record.deactivation_date = now - 1.day
          location.location_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors).to be_empty
        end
      end
    end

    context "when in a crossover period" do
      let(:now) { Time.utc(2023, 5, 1) }

      context "with a deactivation date before the previous collection period" do
        it "does not add an error" do
          record.deactivation_date = now - 2.years
          location.location_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors[:deactivation_date]).to include "The date must be on or after the 1 April 2022"
        end
      end

      context "with a deactivation date in the previous collection period" do
        it "does not add an error" do
          record.deactivation_date = now - 1.year
          location.location_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors).to be_empty
        end
      end

      context "with a deactivation date in the current collection period" do
        it "does not add an error" do
          record.deactivation_date = now - 1.day
          location.location_deactivation_periods.clear
          validator.validate(record)
          expect(record.errors).to be_empty
        end
      end

      context "but the location was created in the current collection period" do
        let(:location) { FactoryBot.create(:location, startdate:) }
        let(:startdate) { now - 2.days }

        context "with a deactivation date in the previous collection period" do
          it "adds an error" do
            record.deactivation_date = now - 1.year
            location.location_deactivation_periods.clear
            validator.validate(record)
            start_date = startdate.to_formatted_s(:govuk_date)
            expect(record.errors[:deactivation_date]).to include "The location cannot be deactivated before #{start_date}, the date when it was first available"
          end
        end
      end
    end
  end
end

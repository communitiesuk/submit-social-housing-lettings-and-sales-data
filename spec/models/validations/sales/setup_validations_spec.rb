require "rails_helper"

RSpec.describe Validations::Sales::SetupValidations do
  subject(:setup_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::SetupValidations } }

  describe "#validate_saledate_collection_year" do
    context "with sales_in_crossover_period == false" do
      before do
        Timecop.freeze(Time.zone.local(2023, 1, 10))
        Singleton.__init__(FormHandler)
      end

      after do
        Timecop.return
      end

      context "when saledate is blank" do
        let(:record) { build(:sales_log, saledate: nil) }

        it "does not add an error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors).to be_empty
        end
      end

      context "when saledate is in the 22/23 collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2023, 1, 1)) }

        it "does not add an error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors).to be_empty
        end
      end

      context "when saledate is before the 22/23 collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2020, 1, 1)) }

        it "adds error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors[:saledate]).to include("Enter a date within the 22/23 collection year, which is between 1st April 2022 and 31st March 2023")
        end
      end

      context "when saledate is after the 22/23 collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2025, 4, 1)) }

        it "adds error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors[:saledate]).to include("Enter a date within the 22/23 collection year, which is between 1st April 2022 and 31st March 2023")
        end
      end
    end

    context "with sales_in_crossover_period == true" do
      around do |example|
        Timecop.freeze(Time.zone.local(2024, 5, 1)) do
          Singleton.__init__(FormHandler)
          example.run
        end
        Timecop.return
      end

      context "when saledate is blank" do
        let(:record) { build(:sales_log, saledate: nil) }

        it "does not add an error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors).to be_empty
        end
      end

      context "when saledate is in the 22/23 collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2024, 1, 1)) }

        it "does not add an error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors).to be_empty
        end
      end

      context "when saledate is before the 22/23 collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2020, 5, 1)) }

        it "adds error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors[:saledate]).to include("Enter a date within the 23/24 or 24/25 collection years, which is between 1st April 2023 and 31st March 2025")
        end
      end

      context "when saledate is after the 22/23 collection year" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2025, 4, 1)) }

        it "adds error" do
          setup_validator.validate_saledate_collection_year(record)

          expect(record.errors[:saledate]).to include("Enter a date within the 23/24 or 24/25 collection years, which is between 1st April 2023 and 31st March 2025")
        end
      end
    end
  end

  describe "#validate_saledate_two_weeks" do
    context "when saledate is blank" do
      let(:record) { build(:sales_log, saledate: nil) }

      it "does not add an error" do
        setup_validator.validate_saledate_two_weeks(record)

        expect(record.errors).to be_empty
      end
    end

    context "when saledate is less than 14 days after today" do
      let(:record) { build(:sales_log, saledate: Time.zone.today + 10.days) }

      it "does not add an error" do
        setup_validator.validate_saledate_two_weeks(record)

        expect(record.errors).to be_empty
      end
    end

    context "when saledate is more than 14 days after today" do
      let(:record) { build(:sales_log, saledate: Time.zone.today + 15.days) }

      it "adds an error" do
        setup_validator.validate_saledate_two_weeks(record)

        expect(record.errors[:saledate]).to include("Sale completion date must not be later than 14 days from today’s date")
      end
    end
  end
end

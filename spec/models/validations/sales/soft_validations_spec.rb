require "rails_helper"

RSpec.describe Validations::Sales::SoftValidations do
  let(:record) { create(:sales_log) }

  describe "income1 min validations" do
    context "when validating soft min" do
      it "returns false if no income1 is given" do
        record.income1 = nil

        expect(record).not_to be_income1_under_soft_min
      end

      it "returns false if no ecstat1 is given" do
        record.ecstat1 = nil

        expect(record).not_to be_income1_under_soft_min
      end

      [
        {
          income1: 4500,
          ecstat1: 1,
        },
        {
          income1: 1400,
          ecstat1: 2,
        },
        {
          income1: 999,
          ecstat1: 3,
        },
        {
          income1: 1899,
          ecstat1: 5,
        },
        {
          income1: 1888,
          ecstat1: 0,
        },
      ].each do |test_case|
        it "returns true if income1 is below soft min for ecstat1 #{test_case[:ecstat1]}" do
          record.income1 = test_case[:income1]
          record.ecstat1 = test_case[:ecstat1]
          expect(record)
            .to be_income1_under_soft_min
        end
      end

      [
        {
          income1: 5001,
          ecstat1: 1,
        },
        {
          income1: 1600,
          ecstat1: 2,
        },
        {
          income1: 1004,
          ecstat1: 3,
        },
        {
          income1: 2899,
          ecstat1: 4,
        },
        {
          income1: 2899,
          ecstat1: 5,
        },
        {
          income1: 5,
          ecstat1: 6,
        },
        {
          income1: 10_888,
          ecstat1: 0,
        },
      ].each do |test_case|
        it "returns false if income1 is over soft min for ecstat1 #{test_case[:ecstat1]}" do
          record.income1 = test_case[:income1]
          record.ecstat1 = test_case[:ecstat1]
          expect(record)
            .not_to be_income1_under_soft_min
        end
      end
    end
  end

  describe "mortgage amount validations" do
    context "when validating soft max" do
      it "returns false if no mortgage is given" do
        record.mortgage = nil
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns false if no inc1mort is given" do
        record.inc1mort = nil
        record.mortgage = 20_000
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns false if no inc2mort is given" do
        record.inc1mort = 2
        record.inc2mort = nil
        record.mortgage = 20_000
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns false if no income1 is given and inc1mort is yes" do
        record.inc1mort = 1
        record.inc2mort = 2
        record.income1 = nil
        record.mortgage = 20_000
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns false if no income2 is given and inc2mort is yes" do
        record.inc1mort = 2
        record.inc2mort = 1
        record.income2 = nil
        record.mortgage = 20_000
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns true if only income1 is used for morgage and it is less than 1/5 of the morgage" do
        record.inc1mort = 1
        record.income1 = 10_000
        record.mortgage = 51_000
        record.inc2mort = 2
        expect(record)
          .to be_mortgage_over_soft_max
      end

      it "returns false if only income1 is used for morgage and it is more than 1/5 of the morgage" do
        record.inc1mort = 1
        record.income1 = 10_000
        record.mortgage = 44_000
        record.inc2mort = 2
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns true if only income2 is used for morgage and it is less than 1/5 of the morgage" do
        record.inc1mort = 2
        record.inc2mort = 1
        record.income2 = 10_000
        record.mortgage = 51_000
        expect(record)
          .to be_mortgage_over_soft_max
      end

      it "returns false if only income2 is used for morgage and it is more than 1/5 of the morgage" do
        record.inc1mort = 2
        record.inc2mort = 1
        record.income2 = 10_000
        record.mortgage = 44_000
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns true if income1 and income2 are used for morgage and their sum is less than 1/5 of the morgage" do
        record.inc1mort = 1
        record.inc2mort = 1
        record.income1 = 10_000
        record.income2 = 10_000
        record.mortgage = 101_000
        expect(record)
          .to be_mortgage_over_soft_max
      end

      it "returns false if income1 and income2 are used for morgage and their sum is more than 1/5 of the morgage" do
        record.inc1mort = 1
        record.inc2mort = 1
        record.income1 = 8_000
        record.income2 = 17_000
        record.mortgage = 124_000
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns true if neither of the incomes are used for morgage and the morgage is more than 0" do
        record.inc1mort = 2
        record.inc2mort = 2
        record.mortgage = 124_000
        expect(record)
          .to be_mortgage_over_soft_max
      end

      it "returns true if neither of the incomes are used for morgage and the morgage is 0" do
        record.inc1mort = 2
        record.inc2mort = 2
        record.mortgage = 0
        expect(record)
          .not_to be_mortgage_over_soft_max
      end
    end
  end

  describe "savings amount validations" do
    context "when validating soft max" do
      it "returns false if no savings is given" do
        record.savings = nil
        expect(record)
          .not_to be_savings_over_soft_max
      end

      it "savings is over 100_000" do
        record.savings = 100_001
        expect(record)
          .to be_savings_over_soft_max
      end

      it "savings is under 100_000" do
        record.savings = 99_999
        expect(record)
          .not_to be_mortgage_over_soft_max
      end
    end
  end

  describe "deposit amount validations" do
    context "when validating soft max" do
      it "returns false if no savings is given" do
        record.savings = nil
        record.deposit = 8_001
        expect(record)
          .not_to be_deposit_over_soft_max
      end

      it "returns false if no deposit is given" do
        record.deposit = nil
        record.savings = 6_000
        expect(record)
          .not_to be_deposit_over_soft_max
      end

      it "returns true if deposit is more than 4/3 of savings" do
        record.deposit = 8_001
        record.savings = 6_000
        expect(record)
          .to be_deposit_over_soft_max
      end

      it "returns fals if deposit is less than 4/3 of savings" do
        record.deposit = 7_999
        record.savings = 6_000
        expect(record)
          .not_to be_deposit_over_soft_max
      end
    end
  end

  describe "hodate_more_than_3_years_before_exdate" do
    it "when hodate not set" do
      record.exdate = Time.zone.now
      record.hodate = nil

      expect(record).not_to be_hodate_3_years_or_more_exdate
    end

    it "when exdate not set" do
      record.exdate = nil
      record.hodate = Time.zone.now

      expect(record).not_to be_hodate_3_years_or_more_exdate
    end

    it "when exdate and hodate not set" do
      record.exdate = nil
      record.hodate = nil

      expect(record).not_to be_hodate_3_years_or_more_exdate
    end

    it "when 3 years or more before exdate" do
      record.exdate = Time.zone.now
      record.hodate = record.exdate - 4.years

      expect(record).to be_hodate_3_years_or_more_exdate
    end

    it "when less than 3 years before exdate" do
      record.exdate = Time.zone.now
      record.hodate = 2.months.ago

      expect(record).not_to be_hodate_3_years_or_more_exdate
    end
  end

  describe "wheelchair_when_not_disabled" do
    it "when hodate not set" do
      record.disabled = 2
      record.wheel = nil

      expect(record).not_to be_wheelchair_when_not_disabled
    end

    it "when disabled not set" do
      record.disabled = nil
      record.wheel = 1

      expect(record).not_to be_wheelchair_when_not_disabled
    end

    it "when disabled and wheel not set" do
      record.disabled = nil
      record.wheel = nil

      expect(record).not_to be_wheelchair_when_not_disabled
    end

    it "when disabled == 2 && wheel == 1" do
      record.disabled = 2
      record.wheel = 1

      expect(record).to be_wheelchair_when_not_disabled
    end

    it "when disabled == 2 && wheel != 1" do
      record.disabled = 2
      record.wheel = 2

      expect(record).not_to be_wheelchair_when_not_disabled
    end
  end

  describe "purchase_price_out_of_soft_range" do
    before do
      LaPurchasePriceRange.create!(
        la: "E07000223",
        bedrooms: 2,
        soft_min: 177000,
        soft_max: 384000,
        start_year: 2022,
        )
    end
    it "when value not set" do
      record.value = nil

      expect(record).not_to be_purchase_price_out_of_soft_range
    end

    it "when beds not set" do
      record.beds = nil

      expect(record).not_to be_purchase_price_out_of_soft_range
    end

    it "when la not set" do
      record.la = nil

      expect(record).not_to be_purchase_price_out_of_soft_range
    end

    it "when saledate not set" do
      record.saledate = nil


      expect(record).not_to be_purchase_price_out_of_soft_range
    end

    it "when below soft min" do
      record.value = 176_999
      record.beds = 2
      record.la = "E07000223"
      record.saledate = Time.zone.local(2023, 1, 1)

      expect(record).to be_purchase_price_out_of_soft_range
    end

    it "when above soft max" do
      record.value = 384_001
      record.beds = 2
      record.la = "E07000223"
      record.saledate = Time.zone.local(2023, 1, 1)

      expect(record).to be_purchase_price_out_of_soft_range
    end

    it "when in soft range" do
      record.value = 200_000
      record.beds = 2
      record.la = "E07000223"
      record.saledate = Time.zone.local(2023, 1, 1)

      expect(record).not_to be_purchase_price_out_of_soft_range
    end
  end
end

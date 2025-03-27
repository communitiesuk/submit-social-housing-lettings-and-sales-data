require "rails_helper"

RSpec.describe Validations::Sales::SoftValidations do
  let(:record) { build(:sales_log) }

  describe "income validations" do
    context "when validating soft range based on ecstat" do
      it "does not trigger for income1 if no income1 is given" do
        record.income1 = nil
        expect(record).not_to be_income1_outside_soft_range_for_ecstat
      end

      it "does not trigger for low income1 if no ecstat1 is given" do
        record.income1 = 50
        record.ecstat1 = nil
        expect(record).not_to be_income1_outside_soft_range_for_ecstat
      end

      it "does not trigger for income2 if no income2 is given" do
        record.income2 = nil
        expect(record).not_to be_income2_outside_soft_range_for_ecstat
      end

      it "does not trigger for low income2 if no ecstat2 is given" do
        record.income2 = 50
        record.ecstat2 = nil
        expect(record).not_to be_income2_outside_soft_range_for_ecstat
      end

      context "when log year is before 2025" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2024, 12, 25)) }

        it "does not trigger for low income1 if ecstat1 has no soft min" do
          record.income1 = 50
          record.ecstat1 = 4
          expect(record).not_to be_income1_outside_soft_range_for_ecstat
        end

        it "returns true if income1 is below soft min for ecstat1" do
          record.income1 = 4500
          record.ecstat1 = 1
          expect(record).to be_income1_outside_soft_range_for_ecstat
        end

        it "returns false if income1 is >= soft min for ecstat1" do
          record.income1 = 1500
          record.ecstat1 = 2
          expect(record).not_to be_income1_outside_soft_range_for_ecstat
        end

        it "does not trigger for income2 if ecstat2 has no soft min" do
          record.income2 = 50
          record.ecstat2 = 8
          expect(record).not_to be_income2_outside_soft_range_for_ecstat
        end

        it "returns true if income2 is below soft min for ecstat2" do
          record.income2 = 999
          record.ecstat2 = 3
          expect(record).to be_income2_outside_soft_range_for_ecstat
        end

        it "returns false if income2 is >= soft min for ecstat2" do
          record.income2 = 2500
          record.ecstat2 = 5
          expect(record).not_to be_income2_outside_soft_range_for_ecstat
        end

        it "does not trigger for being over maxima" do
          record.ecstat1 = 1
          record.income1 = 200_000
          record.ecstat2 = 2
          record.income2 = 100_000
          expect(record).not_to be_income1_outside_soft_range_for_ecstat
          expect(record).not_to be_income2_outside_soft_range_for_ecstat
        end
      end

      context "when log year is 2025" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2025, 12, 25)) }

        it "returns true if income1 is below soft min for ecstat1" do
          record.income1 = 13_399
          record.ecstat1 = 1
          expect(record).to be_income1_outside_soft_range_for_ecstat
        end

        it "returns false if income1 is >= soft min for ecstat1" do
          record.income1 = 2600
          record.ecstat1 = 2
          expect(record).not_to be_income1_outside_soft_range_for_ecstat
        end

        it "returns true if income2 is below soft min for ecstat2" do
          record.income2 = 2079
          record.ecstat2 = 3
          expect(record).to be_income2_outside_soft_range_for_ecstat
        end

        it "returns false if income2 is >= soft min for ecstat2" do
          record.income2 = 520
          record.ecstat2 = 5
          expect(record).not_to be_income2_outside_soft_range_for_ecstat
        end

        it "returns true if income1 is above soft max for ecstat1" do
          record.income1 = 80_001
          record.ecstat1 = 2
          expect(record).to be_income1_outside_soft_range_for_ecstat
        end

        it "returns false if income1 is <= soft max for ecstat1" do
          record.income1 = 80_000
          record.ecstat1 = 2
          expect(record).not_to be_income1_outside_soft_range_for_ecstat
        end

        it "returns true if income2 is above soft max for ecstat2" do
          record.income2 = 50_001
          record.ecstat2 = 6
          expect(record).to be_income2_outside_soft_range_for_ecstat
        end

        it "returns false if income2 is <= soft max for ecstat2" do
          record.income2 = 50_000
          record.ecstat2 = 6
          expect(record).not_to be_income2_outside_soft_range_for_ecstat
        end
      end
    end

    context "when validating soft max for discounted ownership" do
      it "does not trigger if la is not set" do
        record.la = nil
        record.income1 = 100_000
        record.income2 = 95_000
        record.ownershipsch = 2
        expect(record).not_to be_income1_over_soft_max_for_discounted_ownership
        expect(record).not_to be_income2_over_soft_max_for_discounted_ownership
        expect(record).not_to be_combined_income_over_soft_max_for_discounted_ownership
      end

      it "does not trigger if sale is not discounted ownership" do
        record.la = "E09000001"
        record.income1 = 100_000
        record.income2 = 95_000
        record.ownershipsch = 1
        expect(record).not_to be_income1_over_soft_max_for_discounted_ownership
        expect(record).not_to be_income2_over_soft_max_for_discounted_ownership
        expect(record).not_to be_combined_income_over_soft_max_for_discounted_ownership
      end

      context "when property is in London for a discounted ownership sale" do
        let(:record) { build(:sales_log, ownershipsch: 2, la: "E09000001") }

        it "returns true for income1 if income1 > London threshold" do
          record.income1 = 90_001
          expect(record).to be_income1_over_soft_max_for_discounted_ownership
        end

        it "returns false for income1 if income1 <= London threshold" do
          record.income1 = 90_000
          expect(record).not_to be_income1_over_soft_max_for_discounted_ownership
        end

        it "returns true for income2 if income2 > London threshold" do
          record.income2 = 100_000
          expect(record).to be_income2_over_soft_max_for_discounted_ownership
        end

        it "returns false for income2 if income2 <= London threshold" do
          record.income2 = 30_000
          expect(record).not_to be_income2_over_soft_max_for_discounted_ownership
        end

        it "returns true for combined income if > London threshold" do
          record.income1 = 61_000
          record.income2 = 30_000
          expect(record).to be_combined_income_over_soft_max_for_discounted_ownership
        end

        it "returns false for combined income if <= London threshold" do
          record.income1 = 40_000
          record.income2 = 20_000
          expect(record).not_to be_combined_income_over_soft_max_for_discounted_ownership
        end
      end

      context "when property is not in London for a discounted ownership sale" do
        let(:record) { build(:sales_log, ownershipsch: 2, la: "E08000001") }

        it "returns true for income1 if income1 > non-London threshold" do
          record.income1 = 80_001
          expect(record).to be_income1_over_soft_max_for_discounted_ownership
        end

        it "returns false for income1 if income1 <= non-London threshold" do
          record.income1 = 80_000
          expect(record).not_to be_income1_over_soft_max_for_discounted_ownership
        end

        it "returns true for income2 if income2 > non-London threshold" do
          record.income2 = 85_000
          expect(record).to be_income2_over_soft_max_for_discounted_ownership
        end

        it "returns false for income2 if income2 <= non-London threshold" do
          record.income2 = 30_000
          expect(record).not_to be_income2_over_soft_max_for_discounted_ownership
        end

        it "returns true for combined income if > non-London threshold" do
          record.income1 = 61_000
          record.income2 = 20_000
          expect(record).to be_combined_income_over_soft_max_for_discounted_ownership
        end

        it "returns false for combined income if <= non-London threshold" do
          record.income1 = 40_000
          record.income2 = 20_000
          expect(record).not_to be_combined_income_over_soft_max_for_discounted_ownership
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

      it "returns false if no inc2mort is given and it's a joint purchase" do
        record.jointpur = 1
        record.inc1mort = 1
        record.income1 = 10
        record.inc2mort = nil
        record.mortgage = 20_000
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns true if no inc2mort is given and it's not a joint purchase" do
        record.jointpur = 2
        record.inc1mort = 1
        record.income1 = 10
        record.inc2mort = nil
        record.mortgage = 20_000
        expect(record)
          .to be_mortgage_over_soft_max
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

      it "returns true if only income1 is used for mortgage and it is less than 1/5 of the mortgage" do
        record.inc1mort = 1
        record.income1 = 10_000
        record.mortgage = 51_000
        record.inc2mort = 2
        expect(record)
          .to be_mortgage_over_soft_max
      end

      it "returns false if only income1 is used for mortgage and it is more than 1/5 of the mortgage" do
        record.inc1mort = 1
        record.income1 = 10_000
        record.mortgage = 44_000
        record.inc2mort = 2
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns true if only income2 is used for mortgage and it is less than 1/5 of the mortgage" do
        record.inc1mort = 2
        record.inc2mort = 1
        record.income2 = 10_000
        record.mortgage = 51_000
        expect(record)
          .to be_mortgage_over_soft_max
      end

      it "returns false if only income2 is used for mortgage and it is more than 1/5 of the mortgage" do
        record.inc1mort = 2
        record.inc2mort = 1
        record.income2 = 10_000
        record.mortgage = 44_000
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns true if income1 and income2 are used for mortgage and their sum is less than 1/5 of the mortgage" do
        record.inc1mort = 1
        record.inc2mort = 1
        record.income1 = 10_000
        record.income2 = 10_000
        record.mortgage = 101_000
        expect(record)
          .to be_mortgage_over_soft_max
      end

      it "returns false if income1 and income2 are used for mortgage and their sum is more than 1/5 of the mortgage" do
        record.inc1mort = 1
        record.inc2mort = 1
        record.income1 = 8_000
        record.income2 = 17_000
        record.mortgage = 124_000
        expect(record)
          .not_to be_mortgage_over_soft_max
      end

      it "returns true if neither of the incomes are used for mortgage and the mortgage is more than 0" do
        record.inc1mort = 2
        record.inc2mort = 2
        record.mortgage = 124_000
        expect(record)
          .to be_mortgage_over_soft_max
      end

      it "returns false if neither of the incomes are used for mortgage and the mortgage is 0" do
        record.inc1mort = 2
        record.inc2mort = 2
        record.mortgage = 0
        expect(record)
          .not_to be_mortgage_over_soft_max
      end
    end

    context "when validating mortgage and deposit against discounted value" do
      [
        {
          nil_field: "mortgage",
          value: 500_000,
          deposit: 10_000,
          discount: 10,
        },
        {
          nil_field: "value",
          mortgage: 100_000,
          deposit: 10_000,
          discount: 10,
        },
        {
          nil_field: "deposit",
          value: 500_000,
          mortgage: 100_000,
          discount: 10,
        },
        {
          nil_field: "discount",
          value: 500_000,
          mortgage: 100_000,
          deposit: 10_000,
        },
      ].each do |test_case|
        it "returns false if #{test_case[:nil_field]} is not present" do
          record.value = test_case[:value]
          record.mortgage = test_case[:mortgage]
          record.deposit = test_case[:deposit]
          record.discount = test_case[:discount]
          expect(record).not_to be_mortgage_plus_deposit_less_than_discounted_value
        end
      end

      it "returns false if the deposit and mortgage add up to the discounted value or more" do
        record.value = 500_000
        record.discount = 20
        record.mortgage = 200_000
        record.deposit = 200_000
        expect(record).not_to be_mortgage_plus_deposit_less_than_discounted_value
      end

      it "returns true if the deposit and mortgage add up to less than the discounted value" do
        record.value = 500_000
        record.discount = 10
        record.mortgage = 200_000
        record.deposit = 200_000
        expect(record).to be_mortgage_plus_deposit_less_than_discounted_value
      end
    end

    context "when validating extra borrowing" do
      context "when the log is for 2023" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2023, 12, 1)) }

        it "returns false if extrabor not present" do
          record.mortgage = 50_000
          record.deposit = 40_000
          record.value = 100_000
          record.discount = 11
          expect(record)
            .not_to be_extra_borrowing_expected_but_not_reported
        end

        it "returns false if mortgage not present" do
          record.extrabor = 2
          record.deposit = 40_000
          record.value = 100_000
          record.discount = 11
          expect(record)
            .not_to be_extra_borrowing_expected_but_not_reported
        end

        it "returns false if deposit not present" do
          record.extrabor = 2
          record.mortgage = 50_000
          record.value = 100_000
          record.discount = 11
          expect(record)
            .not_to be_extra_borrowing_expected_but_not_reported
        end

        it "returns false if value not present" do
          record.extrabor = 2
          record.mortgage = 50_000
          record.deposit = 40_000
          record.discount = 11
          expect(record)
            .not_to be_extra_borrowing_expected_but_not_reported
        end

        it "returns false if discount not present" do
          record.extrabor = 2
          record.mortgage = 50_000
          record.deposit = 40_000
          record.value = 100_000
          expect(record)
            .not_to be_extra_borrowing_expected_but_not_reported
        end

        it "returns false if extra borrowing expected and reported" do
          record.extrabor = 1
          record.mortgage = 50_000
          record.deposit = 40_000
          record.value = 100_000
          record.discount = 11
          expect(record)
            .not_to be_extra_borrowing_expected_but_not_reported
        end

        it "returns true if extra borrowing expected but not reported" do
          record.extrabor = 2
          record.mortgage = 50_000
          record.deposit = 40_000
          record.value = 100_000
          record.discount = 11
          expect(record)
            .to be_extra_borrowing_expected_but_not_reported
        end
      end

      context "when the log is for 2024" do
        let(:record) { build(:sales_log, saledate: Time.zone.local(2024, 12, 1)) }

        it "returns false for logs from 2024 onwards" do
          record.extrabor = 2
          record.mortgage = 50_000
          record.deposit = 40_000
          record.value = 100_000
          record.discount = 11
          expect(record)
            .not_to be_extra_borrowing_expected_but_not_reported
        end
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

      context "with log for 2025 of after" do
        before do
          record.saledate = Time.zone.local(2025, 5, 1)
        end

        it "allows savings over 100_000 for old persons shared ownership" do
          record.savings = 100_001
          record.type = 24
          expect(record)
            .not_to be_savings_over_soft_max
        end

        it "does not allows savings over 200_000 for old persons shared ownership" do
          record.savings = 200_001
          record.type = 24
          expect(record)
            .to be_savings_over_soft_max
        end

        it "does not allows savings over 100_000 for other type" do
          record.savings = 100_001
          record.type = 8
          expect(record)
            .to be_savings_over_soft_max
        end
      end
    end
  end

  describe "deposit amount validations" do
    context "when validating soft max" do
      it "returns false if no savings is given" do
        record.mortgageused = 1
        record.savings = nil
        record.deposit = 8_001
        expect(record)
          .not_to be_deposit_over_soft_max
      end

      it "returns false if no deposit is given" do
        record.mortgageused = 1
        record.deposit = nil
        record.savings = 6_000
        expect(record)
          .not_to be_deposit_over_soft_max
      end

      it "returns true if deposit is more than 4/3 of savings" do
        record.mortgageused = 1
        record.deposit = 8_001
        record.savings = 6_000
        expect(record)
          .to be_deposit_over_soft_max
      end

      it "returns false if deposit is less than 4/3 of savings" do
        record.mortgageused = 1
        record.deposit = 7_999
        record.savings = 6_000
        expect(record)
          .not_to be_deposit_over_soft_max
      end

      it "returns false if mortgage is not used" do
        record.mortgageused = 2
        record.deposit = 7_999
        record.savings = 6_000
        expect(record)
          .not_to be_deposit_over_soft_max
      end
    end

    context "when validating shared ownership deposit" do
      before do
        record.saledate = Time.zone.local(2023, 4, 3)
      end

      it "returns false if MORTGAGE + DEPOSIT + CASHDIS are equal VALUE * EQUITY/100" do
        record.mortgage = 1000
        record.deposit = 1000
        record.cashdis = 1000
        record.value = 3000
        record.equity = 100

        expect(record)
          .not_to be_shared_ownership_deposit_invalid
      end

      it "returns false if MORTGAGE + DEPOSIT + CASHDIS are within 1£ of VALUE * EQUITY/100" do
        record.mortgage = 500
        record.deposit = 500
        record.cashdis = 500
        record.value = 3001
        record.equity = 50

        expect(record)
          .not_to be_shared_ownership_deposit_invalid
      end

      it "returns false if mortgage is used and no mortgage is given" do
        record.mortgage = nil
        record.deposit = 1000
        record.cashdis = 1000
        record.value = 3000
        record.equity = 100

        expect(record)
          .not_to be_shared_ownership_deposit_invalid
      end

      it "returns true if mortgage is not used and no mortgage is given" do
        record.mortgage = nil
        record.mortgageused = 2
        record.deposit = 1000
        record.cashdis = 1000
        record.value = 3000
        record.equity = 100

        expect(record)
          .to be_shared_ownership_deposit_invalid
      end

      it "returns false if no deposit is given" do
        record.mortgage = 1000
        record.deposit = nil
        record.cashdis = 1000
        record.value = 3000
        record.equity = 100

        expect(record)
          .not_to be_shared_ownership_deposit_invalid
      end

      it "returns false if no cashdis is given and cashdis is routed to" do
        record.mortgage = 1000
        record.deposit = 1000
        record.type = 18
        record.cashdis = nil
        record.value = 3000
        record.equity = 100

        expect(record)
          .not_to be_shared_ownership_deposit_invalid
      end

      it "returns true if no cashdis is given and cashdis is not routed to" do
        record.mortgage = 1000
        record.deposit = 1000
        record.type = 2
        record.cashdis = nil
        record.value = 3000
        record.equity = 100

        expect(record)
          .to be_shared_ownership_deposit_invalid
      end

      it "returns false if no cashdis not routed to and MORTGAGE + DEPOSIT are within 1£ of VALUE * EQUITY/100" do
        record.mortgage = 500
        record.deposit = 500
        record.type = 2
        record.cashdis = nil
        record.value = 1999
        record.equity = 50

        expect(record)
          .not_to be_shared_ownership_deposit_invalid
      end

      it "returns false if no value is given" do
        record.mortgage = 1000
        record.deposit = 1000
        record.cashdis = 1000
        record.value = nil
        record.equity = 100

        expect(record)
          .not_to be_shared_ownership_deposit_invalid
      end

      it "returns false if no equity is given" do
        record.mortgage = 1000
        record.deposit = 1000
        record.cashdis = 1000
        record.value = 3000
        record.equity = nil

        expect(record)
          .not_to be_shared_ownership_deposit_invalid
      end

      it "returns true if MORTGAGE + DEPOSIT + CASHDIS are not equal VALUE * EQUITY/100" do
        record.mortgage = 1000
        record.deposit = 1000
        record.cashdis = 1000
        record.value = 4323
        record.equity = 100

        expect(record)
          .to be_shared_ownership_deposit_invalid
      end

      it "returns false if startyear is after 2024" do
        record.saledate = Time.zone.local(2025, 1, 1)
        record.mortgage = 1000
        record.deposit = 1000
        record.cashdis = 1000
        record.value = 4323
        record.equity = 100

        expect(record)
          .not_to be_shared_ownership_deposit_invalid
      end
    end
  end

  describe "hodate_more_than_3_years_before_saledate" do
    it "when hodate not set" do
      record.saledate = Time.zone.now
      record.hodate = nil

      expect(record).not_to be_hodate_3_years_or_more_saledate
    end

    it "when saledate not set" do
      record.saledate = nil
      record.hodate = Time.zone.now

      expect(record).not_to be_hodate_3_years_or_more_saledate
    end

    it "when saledate and hodate not set" do
      record.saledate = nil
      record.hodate = nil

      expect(record).not_to be_hodate_3_years_or_more_saledate
    end

    it "when 3 years or more before saledate" do
      record.saledate = Time.zone.now
      record.hodate = record.saledate - 4.years

      expect(record).to be_hodate_3_years_or_more_saledate
    end

    it "when less than 3 years before saledate" do
      record.saledate = Time.zone.now
      record.hodate = 2.months.ago

      expect(record).not_to be_hodate_3_years_or_more_saledate
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
      LaSaleRange.create!(
        la: "E07000223",
        bedrooms: 2,
        soft_min: 177_000,
        soft_max: 384_000,
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

  describe "#grant_outside_common_range?" do
    it "returns true if grant is below 9000" do
      record.grant = 1_000
      record.type = 9
      record.saledate = Time.zone.local(2024, 1, 1)

      expect(record).to be_grant_outside_common_range
    end

    it "returns true if grant is above 16000" do
      record.grant = 100_000
      record.type = 9
      record.saledate = Time.zone.local(2024, 1, 1)

      expect(record).to be_grant_outside_common_range
    end

    it "returns false if grant is within expected range" do
      record.grant = 10_000
      record.type = 9
      record.saledate = Time.zone.local(2024, 1, 1)

      expect(record).not_to be_grant_outside_common_range
    end

    it "returns false for logs after 2024 with RTA" do
      record.grant = 100_000
      record.type = 8
      record.saledate = Time.zone.local(2025, 1, 1)

      expect(record).not_to be_grant_outside_common_range
    end

    it "returns false for logs after 2024 with socialBuy" do
      record.grant = 100_000
      record.type = 21
      record.saledate = Time.zone.local(2025, 1, 1)

      expect(record).not_to be_grant_outside_common_range
    end

    it "returns true for logs after 2024 with other type" do
      record.grant = 100_000
      record.type = 9
      record.saledate = Time.zone.local(2025, 1, 1)

      expect(record).to be_grant_outside_common_range
    end
  end

  describe "#staircase_bought_above_fifty" do
    it "returns false when stairbought is not set" do
      record.stairbought = nil

      expect(record).not_to be_staircase_bought_above_fifty
    end

    it "returns false when stairbought is below fifty" do
      record.stairbought = 40

      expect(record).not_to be_staircase_bought_above_fifty
    end

    it "returns true when stairbought is above fifty" do
      record.stairbought = 70

      expect(record).to be_staircase_bought_above_fifty
    end
  end

  describe "#monthly_charges_over_soft_max?" do
    it "returns false if mscharge is not given" do
      record.mscharge = nil
      record.proptype = 4
      record.type = 2

      expect(record).not_to be_monthly_charges_over_soft_max
    end

    it "returns false if proptype is not given" do
      record.mscharge = 999
      record.proptype = nil
      record.type = 2

      expect(record).not_to be_monthly_charges_over_soft_max
    end

    it "returns false if type is not given" do
      record.mscharge = 999
      record.proptype = 4
      record.type = nil

      expect(record).not_to be_monthly_charges_over_soft_max
    end

    context "with old persons shared ownership" do
      it "returns false if the monthly charge is under 550" do
        record.mscharge = 540
        record.proptype = 4
        record.type = 24

        expect(record).not_to be_monthly_charges_over_soft_max
      end

      it "returns true if the monthly charge is over 550" do
        record.mscharge = 999
        record.proptype = 4
        record.type = 24

        expect(record).to be_monthly_charges_over_soft_max
      end
    end

    context "with non old persons type of ownership" do
      it "returns false if the monthly charge is under 300" do
        record.mscharge = 280
        record.proptype = 4
        record.type = 18

        expect(record).not_to be_monthly_charges_over_soft_max
      end

      it "returns true if the monthly charge is over 300" do
        record.mscharge = 400
        record.proptype = 4
        record.type = 18

        expect(record).to be_monthly_charges_over_soft_max
      end
    end
  end

  describe "#person_2_student_not_child?" do
    it "returns false if age is not given" do
      record.age2 = nil
      record.relat2 = "P"
      record.ecstat2 = 7

      expect(record).not_to be_person_2_student_not_child
    end

    it "returns false if retaltionship is not given" do
      record.age2 = 17
      record.relat2 = nil
      record.ecstat2 = 7

      expect(record).not_to be_person_2_student_not_child
    end

    it "returns false if economic status is not given" do
      record.age2 = 17
      record.relat2 = "P"
      record.ecstat2 = nil

      expect(record).not_to be_person_2_student_not_child
    end

    it "returns true if it's a student aged 16-19 and not a child" do
      record.age2 = 17
      record.relat2 = "P"
      record.ecstat2 = 7

      expect(record).to be_person_2_student_not_child
    end
  end

  describe "#person_3_student_not_child?" do
    it "returns false if age is not given" do
      record.age3 = nil
      record.relat3 = "P"
      record.ecstat3 = 7

      expect(record).not_to be_person_3_student_not_child
    end

    it "returns false if retaltionship is not given" do
      record.age3 = 17
      record.relat3 = nil
      record.ecstat3 = 7

      expect(record).not_to be_person_3_student_not_child
    end

    it "returns false if economic status is not given" do
      record.age3 = 17
      record.relat3 = "P"
      record.ecstat3 = nil

      expect(record).not_to be_person_3_student_not_child
    end

    it "returns true if it's a student aged 16-19 and not a child" do
      record.age3 = 17
      record.relat3 = "P"
      record.ecstat3 = 7

      expect(record).to be_person_3_student_not_child
    end
  end

  describe "#discounted_ownership_value_invalid?" do
    context "when grant is routed to" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, value: 30_000, ownershipsch: 2, type: 8, saledate: Time.zone.local(2023, 4, 3)) }

      context "and not provided" do
        before do
          record.grant = nil
        end

        it "returns false" do
          expect(record).not_to be_discounted_ownership_value_invalid
        end
      end

      context "and is provided" do
        it "returns true if mortgage, deposit and grant total does not equal market value" do
          record.grant = 3_000
          expect(record).to be_discounted_ownership_value_invalid
        end

        it "returns false if mortgage, deposit and grant total equals market value" do
          record.grant = 15_000
          expect(record).not_to be_discounted_ownership_value_invalid
        end
      end
    end

    context "when discount is routed to" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, value: 30_000, ownershipsch: 2, type: 9, saledate: Time.zone.local(2023, 4, 3)) }

      context "and not provided" do
        before do
          record.discount = nil
        end

        it "returns false" do
          expect(record).not_to be_discounted_ownership_value_invalid
        end
      end

      context "and is provided" do
        it "returns true if mortgage and deposit total does not equal market value - discount" do
          record.discount = 10
          expect(record).to be_discounted_ownership_value_invalid
        end

        it "returns false if mortgage and deposit total equals market value - discount" do
          record.discount = 50
          expect(record).not_to be_discounted_ownership_value_invalid
        end
      end
    end

    context "when neither discount nor grant is routed to" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, value: 30_000, ownershipsch: 2, type: 29, saledate: Time.zone.local(2023, 4, 3)) }

      it "returns true if mortgage and deposit total does not equal market value" do
        record.deposit = 2_000
        expect(record).to be_discounted_ownership_value_invalid
      end

      it "returns false if mortgage and deposit total equals market value" do
        record.deposit = 20_000
        expect(record).not_to be_discounted_ownership_value_invalid
      end
    end

    context "when mortgage is routed to" do
      let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2, saledate: Time.zone.local(2023, 4, 3)) }

      context "and not provided" do
        before do
          record.mortgage = nil
        end

        it "returns false" do
          expect(record).not_to be_discounted_ownership_value_invalid
        end
      end

      context "and is provided" do
        it "returns true if mortgage, grant and deposit total does not equal market value - discount" do
          record.mortgage = 10
          expect(record).to be_discounted_ownership_value_invalid
        end

        it "returns false if mortgage, grant and deposit total equals market value - discount" do
          record.mortgage = 10_000
          expect(record).not_to be_discounted_ownership_value_invalid
        end
      end
    end

    context "when mortgage is not routed to" do
      let(:record) { FactoryBot.build(:sales_log, mortgageused: 2, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2, saledate: Time.zone.local(2023, 4, 3)) }

      it "returns true if grant and deposit total does not equal market value - discount" do
        expect(record).to be_discounted_ownership_value_invalid
      end

      it "returns false if mortgage, grant and deposit total equals market value - discount" do
        record.grant = 13_000
        expect(record).not_to be_discounted_ownership_value_invalid
      end
    end

    context "when ownership is not discounted" do
      let(:record) { FactoryBot.build(:sales_log, mortgage: 10_000, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 1, saledate: Time.zone.local(2023, 4, 3)) }

      it "returns false" do
        expect(record).not_to be_discounted_ownership_value_invalid
      end
    end

    context "when it is a 2024 log" do
      let(:record) { FactoryBot.build(:sales_log, mortgageused: 1, deposit: 5_000, grant: 3_000, value: 20_000, discount: 10, ownershipsch: 2, saledate: Time.zone.local(2024, 4, 3)) }

      it "returns true if mortgage, grant and deposit total does not equal market value - discount" do
        record.mortgage = 10
        expect(record).not_to be_discounted_ownership_value_invalid
      end
    end
  end

  describe "#buyer1_livein_wrong_for_ownership_type?" do
    context "when it's a shared ownership" do
      let(:record) { FactoryBot.build(:sales_log, ownershipsch: 1) }

      context "and buy1livein is no" do
        before do
          record.buy1livein = 2
        end

        it "returns true" do
          expect(record).to be_buyer1_livein_wrong_for_ownership_type
        end
      end

      context "and buy1livein is yes" do
        before do
          record.buy1livein = 1
        end

        it "returns false" do
          expect(record).not_to be_buyer1_livein_wrong_for_ownership_type
        end
      end
    end
  end

  describe "#percentage_discount_invalid?" do
    context "when property type is Flat (1)" do
      let(:record) { FactoryBot.build(:sales_log, proptype: 1) }

      context "and discount is under 50%" do
        before do
          record.discount = 49
        end

        it "returns false" do
          expect(record).not_to be_percentage_discount_invalid
        end
      end

      context "and discount is over 50%" do
        before do
          record.discount = 51
        end

        it "returns true" do
          expect(record).to be_percentage_discount_invalid
        end
      end
    end

    context "when it's a discounted ownership" do
      let(:record) { FactoryBot.build(:sales_log, ownershipsch: 2) }

      context "and buy1livein is no" do
        before do
          record.buy1livein = 2
        end

        it "returns true" do
          expect(record).to be_buyer1_livein_wrong_for_ownership_type
        end
      end

      context "and buy1livein is yes" do
        before do
          record.buy1livein = 1
        end

        it "returns false" do
          expect(record).not_to be_buyer1_livein_wrong_for_ownership_type
        end
      end
    end

    context "when property type is masionette or bedsit (2)" do
      let(:record) { FactoryBot.build(:sales_log, proptype: 2) }

      context "and discount is under 50%" do
        before do
          record.discount = 49
        end

        it "returns false" do
          expect(record).not_to be_percentage_discount_invalid
        end
      end

      context "and discount is over 50%" do
        before do
          record.discount = 51
        end

        it "returns true" do
          expect(record).to be_percentage_discount_invalid
        end
      end
    end

    context "when it's a outright sale" do
      let(:record) { FactoryBot.build(:sales_log, ownershipsch: 3) }

      context "and buy1livein is no" do
        before do
          record.buy1livein = 2
        end

        it "returns false" do
          expect(record).not_to be_buyer1_livein_wrong_for_ownership_type
        end
      end

      context "and buy1livein is yes" do
        before do
          record.buy1livein = 1
        end

        it "returns false" do
          expect(record).not_to be_buyer1_livein_wrong_for_ownership_type
        end
      end
    end

    context "when property type is House (3)" do
      let(:record) { FactoryBot.build(:sales_log, proptype: 3) }

      context "and discount is under 35%" do
        before do
          record.discount = 34
        end

        it "returns false" do
          expect(record).not_to be_percentage_discount_invalid
        end
      end

      context "and discount is over 35%" do
        before do
          record.discount = 36
        end

        it "returns true" do
          expect(record).to be_percentage_discount_invalid
        end
      end
    end

    context "when ownership is not given" do
      let(:record) { FactoryBot.build(:sales_log, ownershipsch: 3) }

      before do
        record.ownershipsch = nil
      end

      it "returns false" do
        expect(record).not_to be_buyer1_livein_wrong_for_ownership_type
      end
    end
  end

  describe "#buyer2_livein_wrong_for_ownership_type?" do
    context "when it's a shared ownership" do
      let(:record) { FactoryBot.build(:sales_log, ownershipsch: 1, jointpur: 1) }

      context "and buy2livein is no" do
        before do
          record.buy2livein = 2
        end

        it "returns true" do
          expect(record).to be_buyer2_livein_wrong_for_ownership_type
        end
      end

      context "and buy2livein is yes" do
        before do
          record.buy2livein = 1
        end

        it "returns false" do
          expect(record).not_to be_buyer2_livein_wrong_for_ownership_type
        end
      end

      context "and not a joint purchase" do
        before do
          record.buy2livein = 2
          record.jointpur = 2
        end

        it "returns false" do
          expect(record).not_to be_buyer2_livein_wrong_for_ownership_type
        end
      end
    end

    context "when it's a discounted ownership" do
      let(:record) { FactoryBot.build(:sales_log, ownershipsch: 2, jointpur: 1) }

      context "and buy2livein is no" do
        before do
          record.buy2livein = 2
        end

        it "returns true" do
          expect(record).to be_buyer2_livein_wrong_for_ownership_type
        end
      end

      context "and buy2livein is yes" do
        before do
          record.buy2livein = 1
        end

        it "returns false" do
          expect(record).not_to be_buyer2_livein_wrong_for_ownership_type
        end
      end
    end

    context "when it's a outright sale" do
      let(:record) { FactoryBot.build(:sales_log, ownershipsch: 3, jointpur: 1) }

      context "and buy2livein is no" do
        before do
          record.buy2livein = 2
        end

        it "returns false" do
          expect(record).not_to be_buyer2_livein_wrong_for_ownership_type
        end
      end

      context "and buy2livein is yes" do
        before do
          record.buy2livein = 1
        end

        it "returns false" do
          expect(record).not_to be_buyer2_livein_wrong_for_ownership_type
        end
      end
    end

    context "when ownership is not given" do
      let(:record) { FactoryBot.build(:sales_log, ownershipsch: 3, jointpur: 1) }

      before do
        record.ownershipsch = nil
      end

      it "returns false" do
        expect(record).not_to be_buyer2_livein_wrong_for_ownership_type
      end
    end

    context "when property type is Bungalow (4)" do
      let(:record) { FactoryBot.build(:sales_log, proptype: 4) }

      context "and discount is under 35%" do
        before do
          record.discount = 34
        end

        it "returns false" do
          expect(record).not_to be_percentage_discount_invalid
        end
      end

      context "and discount is over 35%" do
        before do
          record.discount = 36
        end

        it "returns true" do
          expect(record).to be_percentage_discount_invalid
        end
      end
    end

    context "when property type is Other (9)" do
      let(:record) { FactoryBot.build(:sales_log, proptype: 9) }

      context "and discount is under 35%" do
        before do
          record.discount = 34
        end

        it "returns false" do
          expect(record).not_to be_percentage_discount_invalid
        end
      end

      context "and discount is over 35%" do
        before do
          record.discount = 36
        end

        it "returns true" do
          expect(record).to be_percentage_discount_invalid
        end
      end
    end

    context "when discount is not given" do
      let(:record) { FactoryBot.build(:sales_log, proptype: 1, discount: nil) }

      it "returns false" do
        expect(record).not_to be_percentage_discount_invalid
      end
    end

    context "when property type is not given" do
      let(:record) { FactoryBot.build(:sales_log, proptype: nil, discount: 51) }

      it "returns false" do
        expect(record).not_to be_percentage_discount_invalid
      end
    end
  end

  describe "#multiple_partners?" do
    let(:record) { FactoryBot.create(:sales_log, :completed, ownershipsch: 1, jointpur: 1) }

    context "when there are multiple partners" do
      before do
        record.hhmemb = 3
        record.relat2 = "P"
        record.relat3 = "P"
      end

      it "returns true" do
        expect(record).to be_multiple_partners
      end
    end

    context "when there are not multiple partners" do
      before do
        record.hhmemb = 2
        record.relat2 = "P"
      end

      it "returns false" do
        expect(record).not_to be_multiple_partners
      end
    end

    context "when hhmemb is more than the number of person details we require for joint purchase" do
      before do
        record.hhmemb = 14
        record.relat2 = "P"
      end

      it "correctly runs the method" do
        expect(record).not_to be_multiple_partners
      end
    end
  end
end

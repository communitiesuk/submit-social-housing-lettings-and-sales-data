require "rails_helper"

RSpec.describe Validations::FinancialValidations do
  subject(:financial_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::FinancialValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "earnings and income frequency" do
    it "when earnings are provided it validates that income frequency must be provided" do
      record.earnings = 500
      record.incfreq = nil
      financial_validator.validate_net_income(record)
      expect(record.errors["incfreq"])
        .to include(match I18n.t("validations.financial.earnings.freq_missing"))
    end

    it "when income frequency is provided it validates that earnings must be provided" do
      record.earnings = nil
      record.incfreq = 0
      financial_validator.validate_net_income(record)
      expect(record.errors["earnings"])
        .to include(match I18n.t("validations.financial.earnings.earnings_missing"))
    end
  end

  describe "benefits proportion validations" do
    context "when the proportion is all" do
      it "validates that the lead tenant is not in full time employment" do
        record.benefits = 0
        record.ecstat1 = 1
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to include(match I18n.t("validations.financial.benefits.part_or_full_time"))
      end

      it "validates that the lead tenant is not in part time employment" do
        record.benefits = 0
        record.ecstat1 = 0
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to include(match I18n.t("validations.financial.benefits.part_or_full_time"))
      end

      it "expects that the lead tenant is not in full-time or part-time employment" do
        record.benefits = 0
        record.ecstat1 = 4
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to be_empty
      end

      it "validates that the tenant's partner is not in full time employment" do
        record.benefits = 0
        record.ecstat2 = 0
        record.relat2 = 0
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to include(match I18n.t("validations.financial.benefits.part_or_full_time"))
      end

      it "expects that the tenant's partner is not in full-time or part-time employment" do
        record.benefits = 0
        record.ecstat2 = 4
        record.relat2 = 0
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to be_empty
      end
    end
  end

  describe "outstanding rent amount validations" do
    context "when outstanding rent or charges is no" do
      it "validates that no shortfall is provided" do
        record.hbrentshortfall = 1
        record.tshortfall = 99
        financial_validator.validate_outstanding_rent_amount(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.tshortfall.outstanding_amount_not_required"))
      end
    end

    context "when outstanding rent or charges is yes" do
      it "expects that a shortfall is provided" do
        record.hbrentshortfall = 0
        record.tshortfall = 99
        financial_validator.validate_outstanding_rent_amount(record)
        expect(record.errors["tshortfall"]).to be_empty
      end
    end
  end

  describe "housing benefit rent shortfall validations" do
    context "when shortfall is yes" do
      it "validates that housing benefit is not none" do
        record.hbrentshortfall = 0
        record.hb = 9
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits"))
      end

      it "validates that housing benefit is not don't know" do
        record.hbrentshortfall = 0
        record.hb = 3
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits"))
      end

      it "validates that housing benefit is not Universal Credit without housing benefit" do
        record.hbrentshortfall = 0
        record.hb = 7
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits"))
      end

      it "validates that housing benefit is provided" do
        record.hbrentshortfall = 0
        record.hb = 1
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"]).to be_empty
      end
    end
  end

  describe "Net income validations" do
    it "validates that the net income is within the expected range for the tenant's employment status" do
      record.earnings = 200
      record.incfreq = 0
      record.ecstat1 = 1
      financial_validator.validate_net_income(record)
      expect(record.errors["earnings"]).to be_empty
    end

    context "when the net income is higher than the hard max for their employment status" do
      it "adds an error" do
        record.earnings = 5000
        record.incfreq = 0
        record.ecstat1 = 1
        financial_validator.validate_net_income(record)
        expect(record.errors["earnings"])
          .to include(match I18n.t("validations.financial.earnings.over_hard_max", hard_max: 1230))
      end
    end

    context "when the net income is lower than the hard min for their employment status" do
      it "adds an error" do
        record.earnings = 50
        record.incfreq = 0
        record.ecstat1 = 1
        financial_validator.validate_net_income(record)
        expect(record.errors["earnings"])
          .to include(match I18n.t("validations.financial.earnings.under_hard_min", hard_min: 90))
      end
    end
  end

  describe "financial validations" do
    context "when currency is negative" do
      it "returns error" do
        record.earnings = -8
        record.brent = -2
        record.scharge = -134
        record.pscharge = -10_024
        record.supcharg = -1

        financial_validator.validate_negative_currency(record)
        expect(record.errors["earnings"])
          .to include(match I18n.t("validations.financial.negative_currency"))
        expect(record.errors["brent"])
          .to include(match I18n.t("validations.financial.negative_currency"))
        expect(record.errors["scharge"])
          .to include(match I18n.t("validations.financial.negative_currency"))
        expect(record.errors["pscharge"])
          .to include(match I18n.t("validations.financial.negative_currency"))
        expect(record.errors["supcharg"])
          .to include(match I18n.t("validations.financial.negative_currency"))
      end
    end

    context "when the field allows decimals" do
      it "correctly co-erces values" do
        record.brent = "20"
        record.pscharge = "0.0"
        record.period = "2"
        financial_validator.validate_numeric_min_max(record)
        expect(record.errors["pscharge"]).to be_empty
      end
    end
  end

  describe "rent and charges validations" do
    context "when shortfall amount is provided" do
      it "validates that basic rent is no less than double the shortfall" do
        record.hbrentshortfall = 1
        record.tshortfall = 99.50
        record.brent = 198
        financial_validator.validate_rent_amount(record)
        expect(record.errors["brent"])
          .to include(match I18n.t("validations.financial.rent.less_than_double_shortfall", shortfall: 198))
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.tshortfall.more_than_rent"))
      end
    end

    context "when the landlord is this landlord" do
      context "when needstype is general needs" do
        before do
          record.needstype = 1
          record.landlord = 1
        end

        [{
          period: { label: "weekly", value: 1 },
          charge: { field: "scharge", value: 56 },
        },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "scharge", value: 300 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 111 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "pscharge", value: 31 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "pscharge", value: 150 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 61 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "supcharg", value: 41 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "supcharg", value: 200 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 81 },
         }].each do |test_case|
          it "does not allow charges outide the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to include(match I18n.t("validations.financial.rent.#{test_case[:charge][:field]}.this_landlord.general_needs"))
          end
        end

        [{
          period: { label: "weekly", value: 1 },
          charge: { field: "scharge", value: 54 },
        },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "scharge", value: 220 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 109 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "pscharge", value: 30 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "pscharge", value: 120 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 59 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "supcharg", value: 39 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "supcharg", value: 120 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 79 },
         }].each do |test_case|
          it "does allow charges inside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to be_empty
          end
        end
      end

      context "when needstype is supported housing" do
        before do
          record.needstype = 0
          record.landlord = 1
        end

        [{
          period: { label: "weekly", value: 1 },
          charge: { field: "scharge", value: 281 },
        },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "scharge", value: 1225 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 561 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "pscharge", value: 201 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "pscharge", value: 1000 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 400.80 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "supcharg", value: 466 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "supcharg", value: 3100 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 990 },
         }].each do |test_case|
          it "does not allow charges outide the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to include(match I18n.t("validations.financial.rent.#{test_case[:charge][:field]}.this_landlord.supported_housing"))
          end
        end

        [{
          period: { label: "weekly", value: 1 },
          charge: { field: "scharge", value: 280 },
        },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "scharge", value: 1200 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 559 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "pscharge", value: 199.99 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "pscharge", value: 800 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 400 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "supcharg", value: 464 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "supcharg", value: 2000 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 880 },
         }].each do |test_case|
          it "does allow charges inside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to be_empty
          end
        end
      end
    end

    context "when the landlord is another RP" do
      context "when needstype is general needs" do
        before do
          record.needstype = 1
          record.landlord = 2
        end

        [{
          period: { label: "weekly", value: 1 },
          charge: { field: "scharge", value: 46 },
        },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "scharge", value: 200 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 91 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "pscharge", value: 36 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "pscharge", value: 190 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 71 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "supcharg", value: 61 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "supcharg", value: 300 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 122 },
         }].each do |test_case|
          it "does not allow charges outide the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to include(match I18n.t("validations.financial.rent.#{test_case[:charge][:field]}.other_landlord.general_needs"))
          end
        end

        [{
          period: { label: "weekly", value: 1 },
          charge: { field: "scharge", value: 44 },
        },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "scharge", value: 160 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 89 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "pscharge", value: 34 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "pscharge", value: 140 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 69 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "supcharg", value: 59.99 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "supcharg", value: 240 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 119 },
         }].each do |test_case|
          it "does allow charges inside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to be_empty
          end
        end
      end

      context "when needstype is supported housing" do
        before do
          record.needstype = 0
          record.landlord = 2
        end

        [{
          period: { label: "weekly", value: 1 },
          charge: { field: "scharge", value: 165.90 },
        },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "scharge", value: 750 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 330.50 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "pscharge", value: 76 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "pscharge", value: 400 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 151 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "supcharg", value: 121 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "supcharg", value: 620 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 241 },
         }].each do |test_case|
          it "does not allow charges outide the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to include(match I18n.t("validations.financial.rent.#{test_case[:charge][:field]}.other_landlord.supported_housing"))
          end
        end

        [{
          period: { label: "weekly", value: 1 },
          charge: { field: "scharge", value: 120.88 },
        },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "scharge", value: 608 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "scharge", value: 329.99 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "pscharge", value: 74 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "pscharge", value: 210 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "pscharge", value: 149 },
         },
         {
           period: { label: "weekly", value: 1 },
           charge: { field: "supcharg", value: 119 },
         },
         {
           period: { label: "monthly", value: 4 },
           charge: { field: "supcharg", value: 480 },
         },
         {
           period: { label: "every 2 weeks", value: 2 },
           charge: { field: "supcharg", value: 239 },
         }].each do |test_case|
          it "does allow charges inside the range when period is #{test_case[:period][:label]}" do
            record.period = test_case[:period][:value]
            record[test_case[:charge][:field]] = test_case[:charge][:value]
            financial_validator.validate_rent_amount(record)
            expect(record.errors[test_case[:charge][:field]])
              .to be_empty
          end
        end
      end

      context "when period is weekly" do
        it "validates that total charge is at least 10 per week" do
          record.period = 1
          record.tcharge = 9
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
                .to include(match I18n.t("validations.financial.tcharge.under_10"))
        end

        it "allows the total charge to be over 10 per week" do
          record.period = 1
          record.tcharge = 10
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
                .to be_empty
        end
      end

      context "when period is every 2 weeks" do
        it "validates that total charge is at least 10 per week" do
          record.period = 2
          record.tcharge = 19.99
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
                .to include(match I18n.t("validations.financial.tcharge.under_10"))
        end

        it "allows the total charge to be over 10 per week" do
          record.period = 2
          record.tcharge = 20
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
                .to be_empty
        end
      end

      context "when entering charges" do
        it "returns an error for 3 charge types selected" do
          record.tcharge = 19.99
          record.chcharge = 20
          record.household_charge = 0
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
          expect(record.errors["chcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
          expect(record.errors["household_charge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
        end

        it "returns an error for tcharge and chcharge types selected" do
          record.tcharge = 19.99
          record.chcharge = 20
          financial_validator.validate_rent_amount(record)
          expect(record.errors["household_charge"])
            .to be_empty
          expect(record.errors["tcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
          expect(record.errors["chcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
        end

        it "returns an error for tcharge and household_charge types selected" do
          record.tcharge = 19.99
          record.household_charge = 0
          financial_validator.validate_rent_amount(record)
          expect(record.errors["chcharge"])
            .to be_empty
          expect(record.errors["tcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
          expect(record.errors["household_charge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
        end

        it "returns an error for chcharge and household_charge types selected" do
          record.chcharge = 20
          record.household_charge = 0
          financial_validator.validate_rent_amount(record)
          expect(record.errors["tcharge"])
            .to be_empty
          expect(record.errors["chcharge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
          expect(record.errors["household_charge"])
            .to include(match I18n.t("validations.financial.charges.complete_1_of_3"))
        end
      end

      it "does not return an error for household_charge being yes" do
        record.household_charge = 0
        financial_validator.validate_rent_amount(record)
        expect(record.errors["tcharge"])
          .to be_empty
        expect(record.errors["chcharge"])
          .to be_empty
        expect(record.errors["household_charge"])
          .to be_empty
      end

      it "does not return an error for chcharge being selected" do
        record.household_charge = 1
        record.chcharge = 20
        financial_validator.validate_rent_amount(record)
        expect(record.errors["tcharge"])
          .to be_empty
        expect(record.errors["chcharge"])
          .to be_empty
        expect(record.errors["household_charge"])
          .to be_empty
      end

      it "does not return an error for tcharge being selected" do
        record.household_charge = 1
        record.tcharge = 19.99
        financial_validator.validate_rent_amount(record)
        expect(record.errors["tcharge"])
          .to be_empty
        expect(record.errors["chcharge"])
          .to be_empty
        expect(record.errors["household_charge"])
          .to be_empty
      end

      context "when validating ranges based on LA and needstype" do
        before do
          LaRentRange.find_or_create_by(
            ranges_rent_id: "1",
            la: "E07000223",
            beds: 1,
            lettype: 1,
            soft_min: 12.41,
            soft_max: 89.54,
            hard_min: 9.87,
            hard_max: 100.99,
            start_year: 2021,
          )
        end

        it "validates hard minimum" do
          record.lettype = 1
          record.period = 1
          record.la = "E07000223"
          record.beds = 1
          record.year = 2021
          record.startdate = Time.zone.local(2021, 9, 17)
          record.brent = 9.17

          financial_validator.validate_rent_amount(record)
          expect(record.errors["brent"])
            .to include(match I18n.t("validations.financial.brent.not_in_range"))
        end

        it "validates hard max" do
          record.lettype = 1
          record.period = 1
          record.la = "E07000223"
          record.beds = 1
          record.startdate = Time.zone.local(2021, 9, 17)
          record.year = 2021
          record.brent = 200

          financial_validator.validate_rent_amount(record)
          expect(record.errors["brent"])
            .to include(match I18n.t("validations.financial.brent.not_in_range"))
          expect(record.errors["beds"])
            .to include(match I18n.t("validations.financial.brent.beds.not_in_range"))
          expect(record.errors["la"])
            .to include(match I18n.t("validations.financial.brent.la.not_in_range"))
          expect(record.errors["rent_type"])
            .to include(match I18n.t("validations.financial.brent.rent_type.not_in_range"))
          expect(record.errors["needstype"])
            .to include(match I18n.t("validations.financial.brent.needstype.not_in_range"))
        end

        it "validates hard max for correct collection year" do
          record.lettype = 1
          record.period = 1
          record.la = "E07000223"
          record.startdate = Time.zone.local(2022, 2, 5)
          record.beds = 1
          record.year = 2022
          record.month = 2
          record.day = 5
          record.brent = 200

          financial_validator.validate_rent_amount(record)
          expect(record.errors["brent"])
            .to include(match I18n.t("validations.financial.brent.not_in_range"))
          expect(record.errors["beds"])
            .to include(match I18n.t("validations.financial.brent.beds.not_in_range"))
          expect(record.errors["la"])
            .to include(match I18n.t("validations.financial.brent.la.not_in_range"))
          expect(record.errors["rent_type"])
            .to include(match I18n.t("validations.financial.brent.rent_type.not_in_range"))
          expect(record.errors["needstype"])
            .to include(match I18n.t("validations.financial.brent.needstype.not_in_range"))
        end

        it "does not error if some of the fields are missing" do
          record.managing_organisation.provider_type = 2
          record.year = 2021
          record.startdate = Time.zone.local(2021, 9, 17)
          record.brent = 200

          financial_validator.validate_rent_amount(record)
          expect(record.errors["brent"])
            .to be_empty
        end
      end
    end
  end
end

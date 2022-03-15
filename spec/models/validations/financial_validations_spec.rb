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
        it "does not allow the scharge to be outside of 0 and 55 range per week when period is weekly" do
          record.needstype = 1
          record.landlord = 1
          record.period = 1
          record.scharge = 56
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to include(match I18n.t("validations.financial.rent.scharge.this_landlord.general_needs"))
        end

        it "does allow the scharge to be between of 0 and 55 per week when period is weekly" do
          record.needstype = 1
          record.landlord = 1
          record.period = 1
          record.scharge = 54
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to be_empty
        end

        it "does not allow the scharge to be outside of 0 and 55 range per week when period is monthly" do
          record.needstype = 1
          record.landlord = 1
          record.period = 4
          record.scharge = 300
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to include(match I18n.t("validations.financial.rent.scharge.this_landlord.general_needs"))
        end

        it "does allow the scharge to be between of 0 and 55 per week when period is monthly" do
          record.needstype = 1
          record.landlord = 1
          record.period = 4
          record.scharge = 220
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to be_empty
        end

        it "does not allow the scharge to be outside of 0 and 55 range per week when period is every 2 weeks" do
          record.needstype = 1
          record.landlord = 1
          record.period = 2
          record.scharge = 111
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to include(match I18n.t("validations.financial.rent.scharge.this_landlord.general_needs"))
        end

        it "does allow the scharge to be between of 0 and 55 per week when period is every 2 weeks" do
          record.needstype = 1
          record.landlord = 1
          record.period = 2
          record.scharge = 109
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to be_empty
        end
      end

      context "when needstype is supported housing" do
        it "does not allow the scharge to be outside of 0 and 280 range per week when period is weekly" do
          record.needstype = 0
          record.landlord = 1
          record.period = 1
          record.scharge = 281
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to include(match I18n.t("validations.financial.rent.scharge.this_landlord.supported_housing"))
        end

        it "does allow the scharge to be between of 0 and 280 per week when period is weekly" do
          record.needstype = 0
          record.landlord = 1
          record.period = 1
          record.scharge = 280
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to be_empty
        end

        it "does not allow the scharge to be outside of 0 and 280 range per week when period is monthly" do
          record.needstype = 0
          record.landlord = 1
          record.period = 4
          record.scharge = 1225
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to include(match I18n.t("validations.financial.rent.scharge.this_landlord.supported_housing"))
        end

        it "does allow the scharge to be between of 0 and 280 per week when period is monthly" do
          record.needstype = 0
          record.landlord = 1
          record.period = 4
          record.scharge = 1200
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to be_empty
        end

        it "does not allow the scharge to be outside of 0 and 280 range per week when period is every 2 weeks" do
          record.needstype = 0
          record.landlord = 1
          record.period = 2
          record.scharge = 561
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to include(match I18n.t("validations.financial.rent.scharge.this_landlord.supported_housing"))
        end

        it "does allow the scharge to be between of 0 and 280 per week when period is every 2 weeks" do
          record.needstype = 0
          record.landlord = 1
          record.period = 2
          record.scharge = 559
          financial_validator.validate_rent_amount(record)
          expect(record.errors["scharge"])
            .to be_empty
        end
      end
    end
  end
end

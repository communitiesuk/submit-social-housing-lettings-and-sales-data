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
      record.incfreq = "Weekly"
      financial_validator.validate_net_income(record)
      expect(record.errors["earnings"])
        .to include(match I18n.t("validations.financial.earnings.earnings_missing"))
    end
  end

  describe "benefits proportion validations" do
    context "when the proportion is all" do
      it "validates that the lead tenant is not in full time employment" do
        record.benefits = "All"
        record.ecstat1 = "Full-time - 30 hours or more"
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to include(match I18n.t("validations.financial.benefits.part_or_full_time"))
      end

      it "validates that the lead tenant is not in part time employment" do
        record.benefits = "All"
        record.ecstat1 = "Part-time - Less than 30 hours"
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to include(match I18n.t("validations.financial.benefits.part_or_full_time"))
      end

      it "expects that the lead tenant is not in full-time or part-time employment" do
        record.benefits = "All"
        record.ecstat1 = "Retired"
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to be_empty
      end

      it "validates that the tenant's partner is not in full time employment" do
        record.benefits = "All"
        record.ecstat2 = "Part-time - Less than 30 hours"
        record.relat2 = "Partner"
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to include(match I18n.t("validations.financial.benefits.part_or_full_time"))
      end

      it "expects that the tenant's partner is not in full-time or part-time employment" do
        record.benefits = "All"
        record.ecstat2 = "Retired"
        record.relat2 = "Partner"
        financial_validator.validate_net_income_uc_proportion(record)
        expect(record.errors["benefits"]).to be_empty
      end
    end
  end

  describe "outstanding rent amount validations" do
    context "when outstanding rent or charges is no" do
      it "validates that no shortfall is provided" do
        record.hbrentshortfall = "No"
        record.tshortfall = 99
        financial_validator.validate_outstanding_rent_amount(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.tshortfall.outstanding_amount_not_required"))
      end
    end

    context "when outstanding rent or charges is yes" do
      it "expects that a shortfall is provided" do
        record.hbrentshortfall = "Yes"
        record.tshortfall = 99
        financial_validator.validate_outstanding_rent_amount(record)
        expect(record.errors["tshortfall"]).to be_empty
      end
    end
  end

  describe "housing benefit rent shortfall validations" do
    context "when shortfall is yes" do
      it "validates that housing benefit is not none" do
        record.hbrentshortfall = "Yes"
        record.hb = "None"
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits"))
      end

      it "validates that housing benefit is not don't know" do
        record.hbrentshortfall = "Yes"
        record.hb = "Don’t know"
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits"))
      end

      it "validates that housing benefit is not Universal Credit without housing benefit" do
        record.hbrentshortfall = "Yes"
        record.hb = "Universal Credit (without housing element)"
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"])
          .to include(match I18n.t("validations.financial.hbrentshortfall.outstanding_no_benefits"))
      end

      it "validates that housing benefit is provided" do
        record.hbrentshortfall = "Yes"
        record.hb = "Housing benefit"
        financial_validator.validate_tshortfall(record)
        expect(record.errors["tshortfall"]).to be_empty
      end
    end
  end
end

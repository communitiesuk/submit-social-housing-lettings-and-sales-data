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
      expect(record.errors["incfreq"]).to include(match I18n.t("validations.financial.earnings.freq_missing"))
    end

    it "when income frequency is provided it validates that earnings must be provided" do
      record.earnings = nil
      record.incfreq = "Weekly"
      financial_validator.validate_net_income(record)
      expect(record.errors["earnings"]).to include(match I18n.t("validations.financial.earnings.earnings_missing"))
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
end

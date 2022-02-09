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
end

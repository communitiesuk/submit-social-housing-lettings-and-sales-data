require "rails_helper"

RSpec.describe Validations::Sales::SharedValidations do
  subject(:household_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::HouseholdValidations } }
  let(:record) { FactoryBot.create(:sales_log) }

  describe "child income validation" do
    it "adds an error when a child has an income greater than 0" do
      record.relat2 = "C"
      record.income2 = 100
      household_validator.validate_relat2(record)
      expect(record.errors["relat2"])
        .to include(match I18n.t("validations.financial.income.child_has_income"))
    end
  end
end

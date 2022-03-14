require "rails_helper"

RSpec.describe Validations::SharedValidations do
  subject(:household_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::SharedValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "numeric min max validations" do
    context "when validating age" do
      it "validates that person 1's age is a number" do
        record.age1 = "random"
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["age1"])
          .to include(match I18n.t("validations.numeric.valid", field: "Lead tenant’s age", min: 16, max: 120))
      end

      it "validates that other household member ages are a number" do
        record.age2 = "random"
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.numeric.valid", field: "Person 2’s age", min: 1, max: 120))
      end

      it "validates that person 1's age is greater than 16" do
        record.age1 = 15
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["age1"])
          .to include(match I18n.t("validations.numeric.valid", field: "Lead tenant’s age", min: 16, max: 120))
      end

      it "validates that other household member ages are greater than 1" do
        record.age2 = 0
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.numeric.valid", field: "Person 2’s age", min: 1, max: 120))
      end

      it "validates that person 1's age is less than 121" do
        record.age1 = 121
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["age1"])
          .to include(match I18n.t("validations.numeric.valid", field: "Lead tenant’s age", min: 16, max: 120))
      end

      it "validates that other household member ages are greater than 121" do
        record.age2 = 123
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.numeric.valid", field: "Person 2’s age", min: 1, max: 120))
      end

      it "validates that person 1's age is between 16 and 120" do
        record.age1 = 63
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["age1"]).to be_empty
      end

      it "validates that other household member ages are between 1 and 120" do
        record.age6 = 45
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["age6"]).to be_empty
      end
    end
  end
end

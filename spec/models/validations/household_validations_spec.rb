require "rails_helper"

RSpec.describe Validations::HouseholdValidations do
  subject(:household_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::HouseholdValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "age validations" do
    it "validates that person 1's age is a number" do
      record.age1 = "random"
      household_validator.validate_person_1_age(record)
      expect(record.errors["age1"])
        .to include(match I18n.t("validations.household.age.must_be_valid", lower_bound: 16))
    end

    it "validates that other household member ages are a number" do
      record.age3 = "random"
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["age3"])
        .to include(match I18n.t("validations.household.age.must_be_valid", lower_bound: 1))
    end

    it "validates that person 1's age is greater than 16" do
      record.age1 = 15
      household_validator.validate_person_1_age(record)
      expect(record.errors["age1"])
        .to include(match I18n.t("validations.household.age.must_be_valid", lower_bound: 16))
    end

    it "validates that other household member ages are greater than 1" do
      record.age4 = 0
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["age4"])
        .to include(match I18n.t("validations.household.age.must_be_valid", lower_bound: 1))
    end

    it "validates that person 1's age is less than 121" do
      record.age1 = 121
      household_validator.validate_person_1_age(record)
      expect(record.errors["age1"])
        .to include(match I18n.t("validations.household.age.must_be_valid", lower_bound: 16))
    end

    it "validates that other household member ages are greater than 121" do
      record.age4 = 123
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["age4"])
        .to include(match I18n.t("validations.household.age.must_be_valid", lower_bound: 1))
    end
  end
end

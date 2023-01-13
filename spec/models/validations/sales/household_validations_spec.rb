require "rails_helper"

RSpec.describe Validations::Sales::HouseholdValidations do
  subject(:household_validator) { validator_class.new }

  let(:record) { FactoryBot.build(:sales_log) }
  let(:validator_class) { Class.new { include Validations::Sales::HouseholdValidations } }

  describe "#validate_number_of_other_people_living_in_the_property" do
    context "when within permitted bounds" do
      it "does not add an error" do
        record.hholdcount = 2
        household_validator.validate_number_of_other_people_living_in_the_property(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when blank" do

      it "does not add an error" do
        record.hholdcount = nil
        household_validator.validate_number_of_other_people_living_in_the_property(record)

        expect(record.errors).not_to be_present
      end
    end

    context "when below lower bound" do

      it "adds an error" do
        record.hholdcount = -1
        household_validator.validate_number_of_other_people_living_in_the_property(record)

        expect(record.errors).to be_present
      end
    end

    context "when higher than upper bound" do

      it "adds an error" do
        record.hholdcount = 5
        household_validator.validate_number_of_other_people_living_in_the_property(record)

        expect(record.errors).to be_present
      end
    end
  end

  describe "household member validations" do
    it "validates that only 1 partner exists" do
      record.relat2 = "P"
      record.relat3 = "P"
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["base"])
        .to include(match I18n.t("validations.household.relat.one_partner"))
    end

    it "expects that a tenant can have a partner" do
      record.relat3 = "P"
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["base"]).to be_empty
    end

    context "when the household contains a person under 16" do
      it "expects that person is a child of the tenant" do
        record.age2 = 14
        record.relat2 = "C"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["relat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end

      it "validates that a person under 16 must not be a partner of the buyer" do
        record.age2 = 14
        record.relat2 = "P"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.household.relat.partner_under_16", person_num: 2))
      end

      it "validates that a person over 20 must not be a child of the buyer" do
        record.age2 = 21
        record.relat2 = "C"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.household.relat.child_over_20", person_num: 2))
      end

      it "validates that a person aged 16-19 who is a student must be a child of the buyer" do
        record.age2 = 18
        record.ecstat2 = "7"
        record.relat2 = "P"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.household.relat.student_16_19_sales", person_num: 2))
      end
    end
  end
end

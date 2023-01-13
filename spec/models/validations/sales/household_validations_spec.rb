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
      it "validates that person must be a child of the tenant" do
        record.age2 = 14
        record.relat2 = "P"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.household.relat.child_under_16", person_num: 2))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.household.age.child_under_16_relat", person_num: 2))
      end

      it "expects that person is a child of the tenant" do
        record.age2 = 14
        record.relat2 = "C"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["relat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end

      it "validates that person's economic status must be Child" do
        record.age2 = 14
        record.ecstat2 = 1
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.household.ecstat.child_under_16", person_num: 2))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.household.age.child_under_16", person_num: 2))
      end

      it "expects that person's economic status is Child" do
        record.age2 = 14
        record.ecstat2 = 9
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end

      it "validates that a person with economic status 'child' must be under 16" do
        record.age2 = 21
        record.relat2 = "C"
        record.ecstat2 = 9
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.household.ecstat.child_over_16", person_num: 2))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.household.age.child_over_16", person_num: 2))
      end
    end

    context "when the household contains a tenant’s child between the ages of 16 and 19" do
      it "validates that person's economic status must be full time student or refused" do
        record.age2 = 17
        record.relat2 = "C"
        record.ecstat2 = 1
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.household.ecstat.student_16_19", person_num: 2))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.household.age.student_16_19", person_num: 2))
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.household.relat.student_16_19", person_num: 2))
      end

      it "expects that person can be a full time student" do
        record.age2 = 17
        record.relat2 = "C"
        record.ecstat2 = 7
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
        expect(record.errors["relat2"]).to be_empty
      end

      it "expects that person can refuse to share their work status" do
        record.age2 = 17
        record.relat2 = "C"
        record.ecstat2 = 10
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
        expect(record.errors["relat2"]).to be_empty
      end
    end

    context "when the household contains a person over 70" do
      it "expects that person under 70 does not need to be retired" do
        record.age2 = 50
        record.ecstat2 = 1
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end

      it "expects that person over 70 is retired" do
        record.age2 = 71
        record.ecstat2 = 5
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end
    end

    context "when the household contains a retired male" do
      it "expects that person is over 65" do
        record.age2 = 66
        record.sex2 = "M"
        record.ecstat2 = 5
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["sex2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end
    end

    context "when the household contains a retired female" do
      it "expects that person is over 60" do
        record.age2 = 61
        record.sex2 = "F"
        record.ecstat2 = 5
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
        expect(record.errors["sex2"]).to be_empty
        expect(record.errors["age2"]).to be_empty
      end
    end
  end
end

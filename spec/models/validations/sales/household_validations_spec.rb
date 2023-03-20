require "rails_helper"

RSpec.describe Validations::Sales::HouseholdValidations do
  subject(:household_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::Sales::HouseholdValidations } }

  describe "household member validations" do
    let(:record) { build(:sales_log) }

    it "validates that only 1 partner exists" do
      record.relat2 = "P"
      record.relat3 = "P"
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["relat2"])
        .to include(match I18n.t("validations.household.relat.one_partner"))
      expect(record.errors["relat3"])
        .to include(match I18n.t("validations.household.relat.one_partner"))
      expect(record.errors["relat4"])
        .not_to include(match I18n.t("validations.household.relat.one_partner"))
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
          .to include(match I18n.t("validations.household.relat.partner_under_16"))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.household.age.partner_under_16"))
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
        record.ecstat2 = 9
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.household.ecstat.child_over_16", person_num: 2))
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.household.age.child_over_16", person_num: 2))
      end
    end

    it "validates that a person over 20 must not be a child of the buyer" do
      record.age2 = 21
      record.relat2 = "C"
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["relat2"])
        .to include(match I18n.t("validations.household.relat.child_over_20"))
      expect(record.errors["age2"])
        .to include(match I18n.t("validations.household.age.child_over_20"))
    end

    it "adds does not add and error for a person aged 16-19 who is a student but not a child of the buyer" do
      record.age2 = 18
      record.ecstat2 = "7"
      record.relat2 = "P"
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["relat2"]).to be_empty
      expect(record.errors["ecstat2"]).to be_empty
      expect(record.errors["age2"]).to be_empty
    end

    it "adds errors for a person aged 16-19 who is a child of the buyer but not a student" do
      record.age2 = 17
      record.ecstat2 = "1"
      record.relat2 = "C"
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["relat2"])
        .to include(match I18n.t("validations.household.relat.student_16_19.cannot_be_child.16_19_not_student"))
      expect(record.errors["age2"])
        .to include(match I18n.t("validations.household.age.student_16_19.cannot_be_16_19.child_not_student"))
      expect(record.errors["ecstat2"])
        .to include(match I18n.t("validations.household.ecstat.student_16_19.must_be_student"))
    end

    it "adds errors for a person who is a child of the buyer and a student but not aged 16-19" do
      record.age2 = 14
      record.ecstat2 = "7"
      record.relat2 = "C"
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["relat2"])
        .to include(match I18n.t("validations.household.relat.student_16_19.cannot_be_child.student_not_16_19"))
      expect(record.errors["age2"])
        .to include(match I18n.t("validations.household.age.student_16_19.must_be_16_19"))
      expect(record.errors["ecstat2"])
        .to include(match I18n.t("validations.household.ecstat.student_16_19.cannot_be_student.child_not_16_19"))
    end
  end

  describe "previous postcode validations" do
    let(:record) { build(:sales_log) }

    context "with a discounted sale" do
      before do
        record.ownershipsch = 2
      end

      it "adds an error when previous and current postcodes are not the same" do
        record.postcode_full = "SO32 3PT"
        record.ppostcode_full = "DN6 7FB"
        household_validator.validate_previous_postcode(record)
        expect(record.errors["postcode_full"])
          .to include(match I18n.t("validations.household.postcode.discounted_ownership"))
        expect(record.errors["ppostcode_full"])
          .to include(match I18n.t("validations.household.postcode.discounted_ownership"))
      end

      it "allows same postcodes" do
        record.postcode_full = "SO32 3PT"
        record.ppostcode_full = "SO32 3PT"
        household_validator.validate_previous_postcode(record)
        expect(record.errors["postcode_full"]).to be_empty
        expect(record.errors["ppostcode_full"]).to be_empty
      end

      it "does not add an error when postcode is missing" do
        record.postcode_full = nil
        record.ppostcode_full = "SO32 3PT"
        household_validator.validate_previous_postcode(record)
        expect(record.errors["postcode_full"]).to be_empty
        expect(record.errors["ppostcode_full"]).to be_empty
      end

      it "does not add an error when previous postcode is missing" do
        record.postcode_full = "SO32 3PT"
        record.ppostcode_full = nil
        household_validator.validate_previous_postcode(record)
        expect(record.errors["postcode_full"]).to be_empty
        expect(record.errors["ppostcode_full"]).to be_empty
      end
    end

    context "without a discounted sale" do
      before do
        record.ownershipsch = 1
      end

      it "allows different postcodes" do
        record.postcode_full = "SO32 3PT"
        record.ppostcode_full = "DN6 7FB"
        household_validator.validate_previous_postcode(record)
        expect(record.errors["postcode_full"]).to be_empty
        expect(record.errors["ppostcode_full"]).to be_empty
      end
    end
  end
end

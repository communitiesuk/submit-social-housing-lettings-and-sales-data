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

    it "validates that person 1's age is between 16 and 120" do
      record.age1 = 63
      household_validator.validate_person_1_age(record)
      expect(record.errors["age1"]).to be_empty
    end

    it "validates that other household member ages are between 1 and 120" do
      record.age6 = 45
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["age6"]).to be_empty
    end
  end

  describe "reasonable preference validations" do
    context "when reasonable preference is given" do
      context "when the tenant was not previously homeless" do
        it "adds an error" do
          record.homeless = "No"
          record.reasonpref = "Yes"
          household_validator.validate_reasonable_preference(record)
          expect(record.errors["reasonpref"])
            .to include(match I18n.t("validations.household.reasonpref.not_homeless"))
          expect(record.errors["homeless"])
            .to include(match I18n.t("validations.household.reasonpref.not_homeless"))
        end
      end

      context "when reasonable preference is given" do
        context "when the tenant was previously homeless" do
          it "does not add an error" do
            record.homeless = "Yes - other homelessness"
            record.reasonpref = "Yes"
            household_validator.validate_reasonable_preference(record)
            expect(record.errors["reasonpref"]).to be_empty
            expect(record.errors["homeless"]).to be_empty
            record.homeless = "Yes - assessed as homeless by a local authority and owed a homelessness duty. Including if threatened with homelessness within 56 days"
            household_validator.validate_reasonable_preference(record)
            expect(record.errors["reasonpref"]).to be_empty
            expect(record.errors["homeless"]).to be_empty
          end
        end
      end
    end

    context "when reasonable preference is not given" do
      it "validates that no reason is needed" do
        record.reasonpref = "No"
        record.rp_homeless = "No"
        household_validator.validate_reasonable_preference(record)
        expect(record.errors["reasonpref"]).to be_empty
      end

      it "validates that no reason is given" do
        record.reasonpref = "No"
        record.rp_medwel = "Yes"
        household_validator.validate_reasonable_preference(record)
        expect(record.errors["reasonable_preference_reason"])
          .to include(match I18n.t("validations.household.reasonable_preference_reason.reason_not_required"))
      end
    end
  end

  describe "pregnancy validations" do
    context "when there are no female tenants" do
      it "validates that pregnancy cannot be yes" do
        record.preg_occ = "Yes"
        record.sex1 = "Male"
        household_validator.validate_pregnancy(record)
        expect(record.errors["preg_occ"])
          .to include(match I18n.t("validations.household.preg_occ.no_female"))
      end

      it "validates that pregnancy cannot be prefer not to say" do
        record.preg_occ = "Prefer not to say"
        record.sex1 = "Male"
        household_validator.validate_pregnancy(record)
        expect(record.errors["preg_occ"])
          .to include(match I18n.t("validations.household.preg_occ.no_female"))
      end
    end

    context "when there are female tenants" do
      context "but they are older than 50" do
        it "validates that pregnancy cannot be yes" do
          record.preg_occ = "Yes"
          record.sex1 = "Female"
          record.age1 = "51"
          household_validator.validate_pregnancy(record)
          expect(record.errors["preg_occ"])
            .to include(match I18n.t("validations.household.preg_occ.no_female"))
        end
      end

      context "and they are the main tenant and under 51" do
        it "pregnancy can be yes" do
          record.preg_occ = "Yes"
          record.sex1 = "Female"
          record.age1 = "32"
          household_validator.validate_pregnancy(record)
          expect(record.errors["preg_occ"]).to be_empty
        end
      end

      context "and they are another household member and under 51" do
        it "pregnancy can be yes" do
          record.preg_occ = "Yes"
          record.sex1 = "Male"
          record.age1 = 25
          record.sex3 = "Female"
          record.age3 = "32"
          household_validator.validate_pregnancy(record)
          expect(record.errors["preg_occ"]).to be_empty
        end
      end
    end
  end
end

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
            record.homeless = "Other homeless - not found statutorily homeless but considered homeless by landlord"
            record.reasonpref = "Yes"
            household_validator.validate_reasonable_preference(record)
            expect(record.errors["reasonpref"]).to be_empty
            expect(record.errors["homeless"]).to be_empty
            record.homeless = "Assessed as homeless (or threatened with homelessness within 56 days) by a local authority and owed a homelessness duty"
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

  describe "reason for leaving last settled home validations" do
    let(:field) { "validations.other_field_not_required" }
    let(:main_field_label) { "reason" }
    let(:other_field_label) { "other reason for leaving last settled home" }
    let(:expected_error) { I18n.t(field, main_field_label:, other_field_label:) }

    context "when reason is other" do
      let(:field) { "validations.other_field_missing" }

      it "validates that a reason is provided" do
        record.reason = "Other"
        record.other_reason_for_leaving_last_settled_home = nil
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["other_reason_for_leaving_last_settled_home"])
          .to include(match(expected_error))
      end

      it "expects that a reason is provided" do
        record.reason = "Other"
        record.other_reason_for_leaving_last_settled_home = "Some unusual reason"
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["other_reason_for_leaving_last_settled_home"]).to be_empty
      end
    end

    context "when reason is not other" do
      it "validates that other reason is not provided" do
        record.reason = "Repossession"
        record.other_reason_for_leaving_last_settled_home = "Some other reason"
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["other_reason_for_leaving_last_settled_home"])
          .to include(match(expected_error))
      end

      it "expects that other reason is not provided" do
        record.reason = "Repossession"
        record.other_reason_for_leaving_last_settled_home = nil
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["other_reason_for_leaving_last_settled_home"]).to be_empty
      end
    end

    context "when reason is don't know" do
      let(:expected_error) { I18n.t("validations.household.underoccupation_benefitcap.dont_know_required") }

      it "validates that under occupation benefit cap is also not known" do
        record.reason = "Don’t know"
        record.underoccupation_benefitcap = "Yes - benefit cap"
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["underoccupation_benefitcap"])
          .to include(match(expected_error))
        expect(record.errors["reason"])
          .to include(match(expected_error))
      end

      it "expects that under occupation benefit cap is also not known" do
        record.reason = "Don’t know"
        record.underoccupation_benefitcap = "Don’t know"
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["underoccupation_benefitcap"]).to be_empty
        expect(record.errors["reason"]).to be_empty
      end
    end
  end

  describe "armed forces validations" do
    context "when the tenant or partner was and is not a member of the armed forces" do
      it "validates that injured in the armed forces is not yes" do
        record.armedforces = "No"
        record.reservist = "Yes"
        household_validator.validate_armed_forces(record)
        expect(record.errors["reservist"])
          .to include(match I18n.t("validations.household.reservist.injury_not_required"))
      end
    end

    context "when the tenant prefers not to say if they were or are in the armed forces" do
      it "validates that injured in the armed forces is not yes" do
        record.armedforces = "Tenant prefers not to say"
        record.reservist = "Yes"
        household_validator.validate_armed_forces(record)
        expect(record.errors["reservist"])
          .to include(match I18n.t("validations.household.reservist.injury_not_required"))
      end
    end

    context "when the tenant was or is a regular member of the armed forces" do
      it "expects that injured in the armed forces can be yes" do
        record.armedforces = "A current or former regular in the UK Armed Forces (excluding National Service)"
        record.reservist = "Yes"
        household_validator.validate_armed_forces(record)
        expect(record.errors["reservist"]).to be_empty
      end
    end

    context "when the tenant was or is a reserve member of the armed forces" do
      it "expects that injured in the armed forces can be yes" do
        record.armedforces = "A current or former reserve in the UK Armed Forces (excluding National Service)"
        record.reservist = "Yes"
        household_validator.validate_armed_forces(record)
        expect(record.errors["reservist"]).to be_empty
      end
    end

    context "when the tenant's partner was or is a member of the armed forces" do
      it "expects that injured in the armed forces can be yes" do
        record.armedforces = "A spouse / civil partner of a UK Armed Forces member who has separated or been bereaved within the last 2 years"
        record.reservist = "Yes"
        household_validator.validate_armed_forces(record)
        expect(record.errors["reservist"]).to be_empty
      end
    end

    context "when the tenant or partner has left the armed forces" do
      it "validates that they served in the armed forces" do
        record.armedforces = "No"
        record.leftreg = "Yes"
        household_validator.validate_armed_forces(record)
        expect(record.errors["leftreg"])
          .to include(match I18n.t("validations.household.leftreg.question_not_required"))
      end

      it "expects that they served in the armed forces" do
        record.armedforces = "A current or former regular in the UK Armed Forces (excluding National Service)"
        record.leftreg = "Yes"
        household_validator.validate_armed_forces(record)
        expect(record.errors["leftreg"]).to be_empty
      end

      it "expects that they served in the armed forces and may have been injured" do
        record.armedforces = "A current or former regular in the UK Armed Forces (excluding National Service)"
        record.leftreg = "Yes"
        record.reservist = "Yes"
        household_validator.validate_armed_forces(record)
        expect(record.errors["leftreg"]).to be_empty
        expect(record.errors["reservist"]).to be_empty
      end
    end
  end

  describe "household member validations" do
    it "validates that only 1 partner exists" do
      record.relat2 = "Partner"
      record.relat3 = "Partner"
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["base"])
        .to include(match I18n.t("validations.household.relat.one_partner"))
    end

    it "expects that a tenant can have a partner" do
      record.relat3 = "Partner"
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["base"]).to be_empty
    end

    context "when the household contains a person under 16" do
      it "validates that person must be a child of the tenant" do
        record.age2 = "14"
        record.relat2 = "Partner"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.household.relat.child_under_16", person_num: 2))
      end

      it "expects that person is a child of the tenant" do
        record.age2 = "14"
        record.relat2 = "Child - includes young adult and grown-up"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["relat2"]).to be_empty
      end

      it "validates that person's economic status must be Child" do
        record.age2 = "14"
        record.ecstat2 = "Full-time - 30 hours or more"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.household.ecstat.child_under_16", person_num: 2))
      end

      it "expects that person's economic status is Child" do
        record.age2 = "14"
        record.ecstat2 = "Child under 16"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end
    end

    context "when the household contains a tenant's child between the ages of 16 and 19" do
      it "validates that person's economic status must be full time student or refused" do
        record.age2 = "17"
        record.relat2 = "Child - includes young adult and grown-up"
        record.ecstat2 = "Full-time - 30 hours or more"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.household.ecstat.student_16_19", person_num: 2))
      end

      it "expects that person can be a full time student" do
        record.age2 = "17"
        record.relat2 = "Child - includes young adult and grown-up"
        record.ecstat2 = "Full-time student"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end

      it "expects that person can refuse to share their work status" do
        record.age2 = "17"
        record.relat2 = "Child - includes young adult and grown-up"
        record.ecstat2 = "Prefer not to say"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end
    end

    context "when the household contains a person over 70" do
      it "validates that person must be retired" do
        record.age2 = "71"
        record.ecstat2 = "Full-time - 30 hours or more"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.household.ecstat.retired_over_70", person_num: 2))
      end

      it "expects that person is retired" do
        record.age2 = "50"
        record.ecstat2 = "Full-time - 30 hours or more"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end
    end

    context "when the household contains a retired male" do
      it "validates that person must be over 65" do
        record.age2 = "64"
        record.sex2 = "Male"
        record.ecstat2 = "Retired"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.household.age.retired_male"))
      end

      it "expects that person is over 65" do
        record.age2 = "66"
        record.sex2 = "Male"
        record.ecstat2 = "Retired"
        household_validator.validate_household_number_of_other_members(record)
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end
    end

    context "when the household contains a retired female" do
      it "validates that person must be over 60" do
        record.age2 = "59"
        record.sex2 = "Female"
        record.ecstat2 = "Retired"
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.household.age.retired_female"))
      end

      it "expects that person is over 60" do
        record.age2 = "61"
        record.sex2 = "Female"
        record.ecstat2 = "Retired"
        household_validator.validate_household_number_of_other_members(record)
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end
    end
  end

  describe "accessibility requirement validations" do
    it "validates that mutually exclusive options can't be selected together" do
      record.housingneeds_a = "Yes"
      record.housingneeds_b = "Yes"
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"])
        .to include(match I18n.t("validations.household.housingneeds_a.one_or_two_choices"))
      record.housingneeds_a = "No"
      record.housingneeds_b = "No"
      record.housingneeds_g = "Yes"
      record.housingneeds_f = "Yes"
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"])
        .to include(match I18n.t("validations.household.housingneeds_a.one_or_two_choices"))
      record.housingneeds_a = "Yes"
      record.housingneeds_g = "Yes"
      record.housingneeds_f = "Yes"
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"])
        .to include(match I18n.t("validations.household.housingneeds_a.one_or_two_choices"))
    end

    it "validates that non-mutually exclusive options can be selected together" do
      record.housingneeds_a = "Yes"
      record.housingneeds_f = "Yes"
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"]).to be_empty
      record.housingneeds_a = "No"
      record.housingneeds_b = "Yes"
      record.housingneeds_f = "Yes"
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"]).to be_empty
      record.housingneeds_b = "No"
      record.housingneeds_c = "Yes"
      record.housingneeds_f = "Yes"
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"]).to be_empty
    end
  end

  describe "referral validations" do
    context "when type of tenancy is not secure" do
      it "cannot be not internal transfer" do
        record.tenancy = "Secure (including flexible)"
        record.referral = "Other social landlord"
        household_validator.validate_referral(record)
        expect(record.errors["referral"])
          .to include(match I18n.t("validations.household.referral.secure_tenancy"))
      end

      it "can be internal transfer" do
        record.tenancy = "Secure (including flexible)"
        record.referral = "Internal transfer"
        household_validator.validate_referral(record)
        expect(record.errors["referral"]).to be_empty
      end
    end
  end
end

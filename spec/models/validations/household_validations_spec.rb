require "rails_helper"

RSpec.describe Validations::HouseholdValidations do
  subject(:household_validator) { validator_class.new }

  let(:validator_class) { Class.new { include Validations::HouseholdValidations } }
  let(:record) { FactoryBot.create(:case_log) }

  describe "age validations" do
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

  describe "reasonable preference validations" do
    context "when reasonable preference is homeless" do
      context "when the tenant was not previously homeless" do
        it "adds an error" do
          record.homeless = 1
          record.rp_homeless = 1
          household_validator.validate_reasonable_preference(record)
          expect(record.errors["reasonable_preference_reason"])
            .to include(match I18n.t("validations.household.reasonpref.not_homeless"))
          expect(record.errors["homeless"])
            .to include(match I18n.t("validations.household.homeless.reasonpref.not_homeless"))
        end
      end

      context "when reasonable preference is given" do
        context "when the tenant was previously homeless" do
          it "does not add an error" do
            record.homeless = 1
            record.reasonpref = 1
            household_validator.validate_reasonable_preference(record)
            expect(record.errors["reasonpref"]).to be_empty
            expect(record.errors["homeless"]).to be_empty
            record.homeless = 0
            household_validator.validate_reasonable_preference(record)
            expect(record.errors["reasonpref"]).to be_empty
            expect(record.errors["homeless"]).to be_empty
          end
        end
      end
    end

    context "when reasonable preference is not given" do
      it "validates that no reason is needed" do
        record.reasonpref = 1
        record.rp_homeless = 0
        household_validator.validate_reasonable_preference(record)
        expect(record.errors["reasonpref"]).to be_empty
      end

      it "validates that no reason is given" do
        record.reasonpref = 2
        record.rp_medwel = 1
        household_validator.validate_reasonable_preference(record)
        expect(record.errors["reasonable_preference_reason"])
          .to include(match I18n.t("validations.household.reasonable_preference_reason.reason_not_required"))
      end
    end
  end

  describe "pregnancy validations" do
    context "when there are no female tenants" do
      it "validates that pregnancy cannot be yes" do
        record.preg_occ = 0
        record.sex1 = "M"
        household_validator.validate_pregnancy(record)
        expect(record.errors["preg_occ"])
          .to include(match I18n.t("validations.household.preg_occ.no_female"))
      end

      it "validates that pregnancy cannot be prefer not to say" do
        record.preg_occ = 2
        record.sex1 = "M"
        household_validator.validate_pregnancy(record)
        expect(record.errors["preg_occ"])
          .to include(match I18n.t("validations.household.preg_occ.no_female"))
      end
    end

    context "when there are female tenants" do
      context "but they are older than 50" do
        it "validates that pregnancy cannot be yes" do
          record.preg_occ = 0
          record.sex1 = "F"
          record.age1 = 51
          household_validator.validate_pregnancy(record)
          expect(record.errors["preg_occ"])
            .to include(match I18n.t("validations.household.preg_occ.no_female"))
        end
      end

      context "and they are the main tenant and under 51" do
        it "pregnancy can be yes" do
          record.preg_occ = 0
          record.sex1 = "F"
          record.age1 = 32
          household_validator.validate_pregnancy(record)
          expect(record.errors["preg_occ"]).to be_empty
        end
      end

      context "and they are another household member and under 51" do
        it "pregnancy can be yes" do
          record.preg_occ = 0
          record.sex1 = "M"
          record.age1 = 25
          record.sex3 = "F"
          record.age3 = 32
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
        record.reason = 31
        record.other_reason_for_leaving_last_settled_home = nil
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["other_reason_for_leaving_last_settled_home"])
          .to include(match(expected_error))
      end

      it "expects that a reason is provided" do
        record.reason = 31
        record.other_reason_for_leaving_last_settled_home = "Some unusual reason"
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["other_reason_for_leaving_last_settled_home"]).to be_empty
      end
    end

    context "when reason is not other" do
      it "validates that other reason is not provided" do
        record.reason = 18
        record.other_reason_for_leaving_last_settled_home = "Some other reason"
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["other_reason_for_leaving_last_settled_home"])
          .to include(match(expected_error))
      end

      it "expects that other reason is not provided" do
        record.reason = 18
        record.other_reason_for_leaving_last_settled_home = nil
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["other_reason_for_leaving_last_settled_home"]).to be_empty
      end
    end

    context "when reason is don't know" do
      let(:expected_error) { I18n.t("validations.household.underoccupation_benefitcap.dont_know_required") }

      it "validates that under occupation benefit cap is also not known" do
        record.reason = 32
        record.underoccupation_benefitcap = 1
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["underoccupation_benefitcap"])
          .to include(match(expected_error))
        expect(record.errors["reason"])
          .to include(match(expected_error))
      end

      it "expects that under occupation benefit cap is also not known" do
        record.reason = 32
        record.underoccupation_benefitcap = 4
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["underoccupation_benefitcap"]).to be_empty
        expect(record.errors["reason"]).to be_empty
      end
    end

    context "when referral is not internal transfer" do
      it "cannot be permanently decanted from another property owned by this landlord" do
        record.reason = 1
        record.referral = 2
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["reason"])
          .to include(match(I18n.t("validations.household.reason.not_internal_transfer")))
        expect(record.errors["referral"])
          .to include(match(I18n.t("validations.household.referral.reason_permanently_decanted")))
      end
    end

    context "when referral is internal transfer" do
      it "can be permanently decanted from another property owned by this landlord" do
        record.reason = 1
        record.referral = 1
        household_validator.validate_reason_for_leaving_last_settled_home(record)
        expect(record.errors["reason"])
          .to be_empty
        expect(record.errors["referral"])
          .to be_empty
      end
    end
  end

  describe "armed forces validations" do
    context "when the tenant or partner was and is not a member of the armed forces" do
      it "validates that injured in the armed forces is not yes" do
        record.armedforces = 3
        record.reservist = 0
        household_validator.validate_armed_forces(record)
        expect(record.errors["reservist"])
          .to include(match I18n.t("validations.household.reservist.injury_not_required"))
      end
    end

    context "when the tenant prefers not to say if they were or are in the armed forces" do
      it "validates that injured in the armed forces is not yes" do
        record.armedforces = 4
        record.reservist = 0
        household_validator.validate_armed_forces(record)
        expect(record.errors["reservist"])
          .to include(match I18n.t("validations.household.reservist.injury_not_required"))
      end
    end

    context "when the tenant was or is a regular member of the armed forces" do
      it "expects that injured in the armed forces can be yes" do
        record.armedforces = 0
        record.reservist = 0
        household_validator.validate_armed_forces(record)
        expect(record.errors["reservist"]).to be_empty
      end
    end

    context "when the tenant was or is a reserve member of the armed forces" do
      it "expects that injured in the armed forces can be yes" do
        record.armedforces = 1
        record.reservist = 0
        household_validator.validate_armed_forces(record)
        expect(record.errors["reservist"]).to be_empty
      end
    end

    context "when the tenant's partner was or is a member of the armed forces" do
      it "expects that injured in the armed forces can be yes" do
        record.armedforces = 2
        record.reservist = 0
        household_validator.validate_armed_forces(record)
        expect(record.errors["reservist"]).to be_empty
      end
    end

    context "when the tenant or partner has left the armed forces" do
      it "validates that they served in the armed forces" do
        record.armedforces = 3
        record.leftreg = 0
        household_validator.validate_armed_forces(record)
        expect(record.errors["leftreg"])
          .to include(match I18n.t("validations.household.leftreg.question_not_required"))
      end

      it "expects that they served in the armed forces" do
        record.armedforces = 0
        record.leftreg = 0
        household_validator.validate_armed_forces(record)
        expect(record.errors["leftreg"]).to be_empty
      end

      it "expects that they served in the armed forces and may have been injured" do
        record.armedforces = 0
        record.leftreg = 0
        record.reservist = 0
        household_validator.validate_armed_forces(record)
        expect(record.errors["leftreg"]).to be_empty
        expect(record.errors["reservist"]).to be_empty
      end
    end
  end

  describe "household member validations" do
    it "validates that only 1 partner exists" do
      record.relat2 = 0
      record.relat3 = 0
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["base"])
        .to include(match I18n.t("validations.household.relat.one_partner"))
    end

    it "expects that a tenant can have a partner" do
      record.relat3 = 0
      household_validator.validate_household_number_of_other_members(record)
      expect(record.errors["base"]).to be_empty
    end

    context "when the household contains a person under 16" do
      it "validates that person must be a child of the tenant" do
        record.age2 = 14
        record.relat2 = 0
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["relat2"])
          .to include(match I18n.t("validations.household.relat.child_under_16", person_num: 2))
      end

      it "expects that person is a child of the tenant" do
        record.age2 = 14
        record.relat2 = 1
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["relat2"]).to be_empty
      end

      it "validates that person's economic status must be Child" do
        record.age2 = 14
        record.ecstat2 = 1
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.household.ecstat.child_under_16", person_num: 2))
      end

      it "expects that person's economic status is Child" do
        record.age2 = 14
        record.ecstat2 = 8
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end
    end

    context "when the household contains a tenant's child between the ages of 16 and 19" do
      it "validates that person's economic status must be full time student or refused" do
        record.age2 = 17
        record.relat2 = 1
        record.ecstat2 = 1
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.household.ecstat.student_16_19", person_num: 2))
      end

      it "expects that person can be a full time student" do
        record.age2 = 17
        record.relat2 = 1
        record.ecstat2 = 6
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end

      it "expects that person can refuse to share their work status" do
        record.age2 = 17
        record.relat2 = 1
        record.ecstat2 = 10
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end
    end

    context "when the household contains a person over 70" do
      it "validates that person must be retired" do
        record.age2 = 71
        record.ecstat2 = 1
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"])
          .to include(match I18n.t("validations.household.ecstat.retired_over_70", person_num: 2))
      end

      it "expects that person is retired" do
        record.age2 = 50
        record.ecstat2 = 1
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end
    end

    context "when the household contains a retired male" do
      it "validates that person must be over 65" do
        record.age2 = 64
        record.sex2 = "M"
        record.ecstat2 = 4
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.household.age.retired_male"))
      end

      it "expects that person is over 65" do
        record.age2 = 66
        record.sex2 = "M"
        record.ecstat2 = 4
        household_validator.validate_household_number_of_other_members(record)
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end

      it "validates that the number of other household members cannot be less than 0" do
        record.other_hhmemb = -1
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["other_hhmemb"])
          .to include(match I18n.t("validations.numeric.valid", field: "Number of Other Household Members", min: 0, max: 7))
      end

      it "validates that the number of other household members cannot be more than 7" do
        record.other_hhmemb = 8
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["other_hhmemb"])
          .to include(match I18n.t("validations.numeric.valid", field: "Number of Other Household Members", min: 0, max: 7))
      end

      it "expects that the number of other household members is between the min and max" do
        record.other_hhmemb = 5
        household_validator.validate_numeric_min_max(record)
        expect(record.errors["other_hhmemb"]).to be_empty
      end
    end

    context "when the household contains a retired female" do
      it "validates that person must be over 60" do
        record.age2 = 59
        record.sex2 = "F"
        record.ecstat2 = 4
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["age2"])
          .to include(match I18n.t("validations.household.age.retired_female"))
      end

      it "expects that person is over 60" do
        record.age2 = 61
        record.sex2 = "F"
        record.ecstat2 = 4
        household_validator.validate_household_number_of_other_members(record)
        household_validator.validate_household_number_of_other_members(record)
        expect(record.errors["ecstat2"]).to be_empty
      end
    end
  end

  describe "condition effects validation" do
    it "validates vision can't be selected if answer to anyone in household with health condition is not yes" do
      record.illness = 1
      record.illness_type_1 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"])
        .to include(match I18n.t("validations.household.condition_effects.no_choices"))
    end

    it "validates hearing can't be selected if answer to anyone in household with health condition is not yes" do
      record.illness = 1
      record.illness_type_2 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"])
        .to include(match I18n.t("validations.household.condition_effects.no_choices"))
    end

    it "validates mobility can't be selected if answer to anyone in household with health condition is not yes" do
      record.illness = 1
      record.illness_type_3 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"])
        .to include(match I18n.t("validations.household.condition_effects.no_choices"))
    end

    it "validates dexterity can't be selected if answer to anyone in household with health condition is not yes" do
      record.illness = 1
      record.illness_type_4 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"])
        .to include(match I18n.t("validations.household.condition_effects.no_choices"))
    end

    it "validates learning or understanding or concentrating can't be selected if answer to anyone in household with health condition is not yes" do
      record.illness = 1
      record.illness_type_5 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"])
        .to include(match I18n.t("validations.household.condition_effects.no_choices"))
    end

    it "validates memory can't be selected if answer to anyone in household with health condition is not yes" do
      record.illness = 1
      record.illness_type_6 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"])
        .to include(match I18n.t("validations.household.condition_effects.no_choices"))
    end

    it "validates mental health can't be selected if answer to anyone in household with health condition is not yes" do
      record.illness = 1
      record.illness_type_7 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"])
        .to include(match I18n.t("validations.household.condition_effects.no_choices"))
    end

    it "validates stamina or breathing or fatigue can't be selected if answer to anyone in household with health condition is not yes" do
      record.illness = 1
      record.illness_type_8 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"])
        .to include(match I18n.t("validations.household.condition_effects.no_choices"))
    end

    it "validates socially or behaviourally can't be selected if answer to anyone in household with health condition is not yes" do
      record.illness = 1
      record.illness_type_9 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"])
        .to include(match I18n.t("validations.household.condition_effects.no_choices"))
    end

    it "validates other can't be selected if answer to anyone in household with health condition is not yes" do
      record.illness = 1
      record.illness_type_10 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"])
        .to include(match I18n.t("validations.household.condition_effects.no_choices"))
    end

    it "expects that an illness can be selected if answer to anyone in household with health condition is yes " do
      record.illness = 0
      record.illness_type_1 = 1
      record.illness_type_2 = 1
      record.illness_type_3 = 1
      household_validator.validate_condition_effects(record)
      expect(record.errors["condition_effects"]).to be_empty
    end
  end

  describe "accessibility requirement validations" do
    it "validates that mutually exclusive options can't be selected together" do
      record.housingneeds_a = 1
      record.housingneeds_b = 1
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"])
        .to include(match I18n.t("validations.household.housingneeds_a.one_or_two_choices"))
      record.housingneeds_a = 0
      record.housingneeds_b = 0
      record.housingneeds_g = 1
      record.housingneeds_f = 1
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"])
        .to include(match I18n.t("validations.household.housingneeds_a.one_or_two_choices"))
      record.housingneeds_a = 1
      record.housingneeds_g = 1
      record.housingneeds_f = 1
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"])
        .to include(match I18n.t("validations.household.housingneeds_a.one_or_two_choices"))
    end

    it "validates that non-mutually exclusive options can be selected together" do
      record.housingneeds_a = 1
      record.housingneeds_f = 1
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"]).to be_empty
      record.housingneeds_a = 0
      record.housingneeds_b = 1
      record.housingneeds_f = 1
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"]).to be_empty
      record.housingneeds_b = 0
      record.housingneeds_c = 1
      record.housingneeds_f = 1
      household_validator.validate_accessibility_requirements(record)
      expect(record.errors["accessibility_requirements"]).to be_empty
    end
  end

  describe "referral validations" do
    context "when homelessness is assessed" do
      it "cannot be internal transfer" do
        record.homeless = 11
        record.referral = 1
        household_validator.validate_referral(record)
        expect(record.errors["referral"])
          .to include(match I18n.t("validations.household.referral.assessed_homeless"))
        expect(record.errors["homeless"])
          .to include(match I18n.t("validations.household.homeless.assessed.internal_transfer"))
      end

      it "can be non internal transfer" do
        record.homeless = 0
        record.referral = 3
        household_validator.validate_referral(record)
        expect(record.errors["referral"]).to be_empty
        expect(record.errors["homeless"]).to be_empty
      end
    end

    context "when homelessness is other" do
      it "cannot be internal transfer" do
        record.referral = 1
        record.homeless = 7
        household_validator.validate_referral(record)
        expect(record.errors["referral"])
          .to include(match I18n.t("validations.household.referral.other_homeless"))
        expect(record.errors["homeless"])
          .to include(match I18n.t("validations.household.homeless.other.internal_transfer"))
      end

      it "can be non internal transfer" do
        record.referral = 3
        record.homeless = 1
        household_validator.validate_referral(record)
        expect(record.errors["referral"]).to be_empty
        expect(record.errors["homeless"]).to be_empty
      end
    end
  end

  describe "la validations" do
    context "when previous la is known" do
      it "prevloc has to be provided" do
        record.previous_la_known = 1
        household_validator.validate_prevloc(record)
        expect(record.errors["prevloc"])
          .to include(match I18n.t("validations.household.previous_la_known"))
      end
    end
  end

  describe "previous housing situation validations" do
    context "when the property is being relet to a previously temporary tenant" do
      it "validates that previous tenancy was temporary" do
        record.rsnvac = 2
        record.prevten = 4
        household_validator.validate_previous_housing_situation(record)
        expect(record.errors["prevten"])
          .to include(match I18n.t("validations.household.prevten.non_temp_accommodation"))
      end
    end

    context "when the lead tenant is over 20" do
      it "cannot be children's home/foster care" do
        record.prevten = 13
        record.age1 = 21
        household_validator.validate_previous_housing_situation(record)
        expect(record.errors["prevten"])
          .to include(match I18n.t("validations.household.prevten.over_20_foster_care"))
        expect(record.errors["age1"])
          .to include(match I18n.t("validations.household.age.lead.over_20"))
      end
    end

    context "when the lead tenant is male" do
      it "cannot be refuge" do
        record.prevten = 21
        record.sex1 = "M"
        household_validator.validate_previous_housing_situation(record)
        expect(record.errors["prevten"])
          .to include(match I18n.t("validations.household.prevten.male_refuge"))
        expect(record.errors["sex1"])
          .to include(match I18n.t("validations.household.gender.male_refuge"))
      end
    end

    context "when the referral is internal transfer" do
      it "cannot be 3" do
        record.referral = 1
        record.prevten = 3
        household_validator.validate_previous_housing_situation(record)
        expect(record.errors["prevten"])
          .to include(match I18n.t("validations.household.prevten.internal_transfer", prevten: ""))
        expect(record.errors["referral"])
          .to include(match I18n.t("validations.household.referral.prevten_invalid", prevten: ""))
      end

      it "cannot be 4, 10, 13, 19, 23, 24, 25, 26, 28, 29" do
        record.referral = 1
        record.prevten = 4
        household_validator.validate_previous_housing_situation(record)
        expect(record.errors["prevten"])
          .to include(match I18n.t("validations.household.prevten.internal_transfer", prevten: ""))
        expect(record.errors["referral"])
          .to include(match I18n.t("validations.household.referral.prevten_invalid", prevten: ""))
      end
    end
  end
end

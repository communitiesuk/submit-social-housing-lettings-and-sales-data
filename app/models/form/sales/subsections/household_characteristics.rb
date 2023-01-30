class Form::Sales::Subsections::HouseholdCharacteristics < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_characteristics"
    @label = "Household characteristics"
    @depends_on = [{ "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::BuyerInterview.new(nil, nil, self),
      Form::Sales::Pages::PrivacyNotice.new(nil, nil, self),
      Form::Sales::Pages::Age1.new(nil, nil, self),
      Form::Sales::Pages::RetirementValueCheck.new("age_1_retirement_value_check", nil, self, person_index: 1),
      Form::Sales::Pages::OldPersonsSharedOwnershipValueCheck.new("age_1_old_persons_shared_ownership_value_check", nil, self),
      Form::Sales::Pages::GenderIdentity1.new(nil, nil, self),
      Form::Sales::Pages::RetirementValueCheck.new("gender_1_retirement_value_check", nil, self, person_index: 1),
      Form::Sales::Pages::Buyer1EthnicGroup.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundBlack.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundAsian.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundArab.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundMixed.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundWhite.new(nil, nil, self),
      Form::Sales::Pages::Nationality1.new(nil, nil, self),
      Form::Sales::Pages::Buyer1WorkingSituation.new(nil, nil, self),
      Form::Sales::Pages::RetirementValueCheck.new("working_situation_1_retirement_value_check", nil, self, person_index: 1),
      Form::Sales::Pages::Buyer1IncomeValueCheck.new("working_situation_buyer_1_income_value_check", nil, self),
      Form::Sales::Pages::Buyer1LiveInProperty.new(nil, nil, self),
      Form::Sales::Pages::Buyer2RelationshipToBuyer1.new(nil, nil, self),
      Form::Sales::Pages::Age2.new(nil, nil, self),
      Form::Sales::Pages::OldPersonsSharedOwnershipValueCheck.new("age_2_old_persons_shared_ownership_value_check", nil, self),
      Form::Sales::Pages::GenderIdentity2.new(nil, nil, self),
      Form::Sales::Pages::Buyer2WorkingSituation.new(nil, nil, self),
      Form::Sales::Pages::Buyer2LiveInProperty.new(nil, nil, self),
      Form::Sales::Pages::NumberOfOthersInProperty.new(nil, nil, self),
      Form::Sales::Pages::PersonKnown.new("person_2_known", nil, self, person_index: 2),
      Form::Sales::Pages::PersonRelationshipToBuyer1.new("person_2_relationship_to_buyer_1", nil, self, person_index: 2),
      Form::Sales::Pages::PersonAge.new("person_2_age", nil, self, person_index: 2),
      Form::Sales::Pages::RetirementValueCheck.new("age_2_retirement_value_check", nil, self, person_index: 2),
      Form::Sales::Pages::PersonGenderIdentity.new("person_2_gender_identity", nil, self, person_index: 2),
      Form::Sales::Pages::RetirementValueCheck.new("gender_2_retirement_value_check", nil, self, person_index: 2),
      Form::Sales::Pages::PersonWorkingSituation.new("person_2_working_situation", nil, self, person_index: 2),
      Form::Sales::Pages::PersonKnown.new("person_3_known", nil, self, person_index: 3),
      Form::Sales::Pages::PersonRelationshipToBuyer1.new("person_3_relationship_to_buyer_1", nil, self, person_index: 3),
      Form::Sales::Pages::PersonAge.new("person_3_age", nil, self, person_index: 3),
      Form::Sales::Pages::RetirementValueCheck.new("age_3_retirement_value_check", nil, self, person_index: 3),
      Form::Sales::Pages::PersonGenderIdentity.new("person_3_gender_identity", nil, self, person_index: 3),
      Form::Sales::Pages::RetirementValueCheck.new("gender_3_retirement_value_check", nil, self, person_index: 3),
      Form::Sales::Pages::PersonWorkingSituation.new("person_3_working_situation", nil, self, person_index: 3),
      Form::Sales::Pages::RetirementValueCheck.new("working_situation_3_retirement_value_check", nil, self, person_index: 3),
      Form::Sales::Pages::PersonKnown.new("person_4_known", nil, self, person_index: 4),
      Form::Sales::Pages::PersonRelationshipToBuyer1.new("person_4_relationship_to_buyer_1", nil, self, person_index: 4),
      Form::Sales::Pages::PersonAge.new("person_4_age", nil, self, person_index: 4),
      Form::Sales::Pages::RetirementValueCheck.new("age_4_retirement_value_check", nil, self, person_index: 4),
      Form::Sales::Pages::PersonGenderIdentity.new("person_4_gender_identity", nil, self, person_index: 4),
      Form::Sales::Pages::RetirementValueCheck.new("gender_4_retirement_value_check", nil, self, person_index: 4),
      Form::Sales::Pages::PersonWorkingSituation.new("person_4_working_situation", nil, self, person_index: 4),
      Form::Sales::Pages::RetirementValueCheck.new("working_situation_4_retirement_value_check", nil, self, person_index: 4),
      Form::Sales::Pages::PersonKnown.new("person_5_known", nil, self, person_index: 5),
      Form::Sales::Pages::PersonRelationshipToBuyer1.new("person_5_relationship_to_buyer_1", nil, self, person_index: 5),
      Form::Sales::Pages::PersonAge.new("person_5_age", nil, self, person_index: 5),
      Form::Sales::Pages::RetirementValueCheck.new("age_5_retirement_value_check", nil, self, person_index: 5),
      Form::Sales::Pages::PersonGenderIdentity.new("person_5_gender_identity", nil, self, person_index: 5),
      Form::Sales::Pages::RetirementValueCheck.new("gender_5_retirement_value_check", nil, self, person_index: 5),
      Form::Sales::Pages::PersonWorkingSituation.new("person_5_working_situation", nil, self, person_index: 5),
      Form::Sales::Pages::RetirementValueCheck.new("working_situation_5_retirement_value_check", nil, self, person_index: 5),
    ]
  end
end

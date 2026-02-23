class Form::Lettings::Subsections::HouseholdCharacteristics < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_characteristics"
    @label = "Household characteristics"
    @depends_on = [{ "non_location_setup_questions_completed?" => true }]
  end

  def pages
    @pages ||= [
      (Form::Lettings::Pages::Declaration.new(nil, nil, self) unless form.start_year_2024_or_later?),
      Form::Lettings::Pages::HouseholdMembers.new(nil, nil, self),
      (Form::Lettings::Pages::NoFemalesPregnantHouseholdLeadHhmembValueCheck.new(nil, nil, self) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdLeadHhmembValueCheck.new(nil, nil, self) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::NoHouseholdMemberLikelyToBePregnantCheck.new("no_household_member_likely_to_be_pregnant_hhmemb_check", nil, self) if form.start_year_2026_or_later?),
      Form::Lettings::Pages::LeadTenantAge.new(nil, nil, self),
      (Form::Lettings::Pages::NoFemalesPregnantHouseholdLeadAgeValueCheck.new(nil, nil, self) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdLeadAgeValueCheck.new(nil, nil, self) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::NoHouseholdMemberLikelyToBePregnantCheck.new("no_household_member_likely_to_be_pregnant_lead_age_check", nil, self) if form.start_year_2026_or_later?),
      Form::Lettings::Pages::LeadTenantUnderRetirementValueCheck.new("age_lead_tenant_under_retirement_value_check", nil, self),
      Form::Lettings::Pages::LeadTenantOverRetirementValueCheck.new("age_lead_tenant_over_retirement_value_check", nil, self),
      (Form::Lettings::Pages::LeadTenantSexRegisteredAtBirth.new(nil, nil, self) if form.start_year_2026_or_later?),
      (Form::Lettings::Pages::LeadTenantGenderSameAsSex.new(nil, nil, self) if form.start_year_2026_or_later?),
      (Form::Lettings::Pages::LeadTenantGenderIdentity.new(nil, nil, self) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::NoFemalesPregnantHouseholdLeadValueCheck.new(nil, nil, self) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdLeadValueCheck.new(nil, nil, self) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::NoHouseholdMemberLikelyToBePregnantCheck.new("no_household_member_likely_to_be_pregnant_lead_check", nil, self, person_index: 1) if form.start_year_2026_or_later?),
      Form::Lettings::Pages::LeadTenantOverRetirementValueCheck.new("gender_lead_tenant_over_retirement_value_check", nil, self),
      Form::Lettings::Pages::LeadTenantEthnicGroup.new(nil, nil, self),
      Form::Lettings::Pages::LeadTenantEthnicBackgroundArab.new(nil, nil, self),
      Form::Lettings::Pages::LeadTenantEthnicBackgroundAsian.new(nil, nil, self),
      Form::Lettings::Pages::LeadTenantEthnicBackgroundBlack.new(nil, nil, self),
      Form::Lettings::Pages::LeadTenantEthnicBackgroundMixed.new(nil, nil, self),
      Form::Lettings::Pages::LeadTenantEthnicBackgroundWhite.new(nil, nil, self),
      Form::Lettings::Pages::LeadTenantNationality.new(nil, nil, self),
      Form::Lettings::Pages::LeadTenantWorkingSituation.new(nil, nil, self),
      Form::Lettings::Pages::LeadTenantUnderRetirementValueCheck.new("working_situation_lead_tenant_under_retirement_value_check", nil, self),
      Form::Lettings::Pages::LeadTenantOverRetirementValueCheck.new("working_situation_lead_tenant_over_retirement_value_check", nil, self),
      (Form::Lettings::Pages::WorkingSituationIllnessCheckLead.new("working_situation_lead_tenant_long_term_illness_check", nil, self) if form.start_year_2026_or_later?),
      *person_questions(person_index: 2),
      *person_questions(person_index: 3),
      *person_questions(person_index: 4),
      *person_questions(person_index: 5),
      *person_questions(person_index: 6),
      *person_questions(person_index: 7),
      *person_questions(person_index: 8),
    ].compact
  end

  def person_questions(person_index:)
    [
      Form::Lettings::Pages::PersonKnown.new(nil, nil, self, person_index:),
      (Form::Lettings::Pages::PersonAge.new(nil, nil, self, person_index:) if form.start_year_2026_or_later?),
      relationship_question(person_index:),
      (Form::Lettings::Pages::PartnerUnder16ValueCheck.new("relationship_#{person_index}_partner_under_16_value_check", nil, self, person_index:) if form.start_year_2024_or_later? && !form.start_year_2026_or_later?),
      (Form::Lettings::Pages::MultiplePartnersValueCheck.new("relationship_#{person_index}_multiple_partners_value_check", nil, self, person_index:) if form.start_year_2024_or_later?),
      (Form::Lettings::Pages::PersonAge.new(nil, nil, self, person_index:) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::NoFemalesPregnantHouseholdPersonAgeValueCheck.new(nil, nil, self, person_index:) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdPersonAgeValueCheck.new(nil, nil, self, person_index:) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::NoHouseholdMemberLikelyToBePregnantCheck.new("no_household_member_likely_to_be_pregnant_person_age_#{person_index}_check", nil, self, person_index:) if form.start_year_2026_or_later?),
      Form::Lettings::Pages::PersonUnderRetirementValueCheck.new("age_#{person_index}_under_retirement_value_check", nil, self, person_index:),
      Form::Lettings::Pages::PersonOverRetirementValueCheck.new("age_#{person_index}_over_retirement_value_check", nil, self, person_index:),
      (Form::Lettings::Pages::PartnerUnder16ValueCheck.new("age_#{person_index}_partner_under_16_value_check", nil, self, person_index:) if form.start_year_2024_or_later? && !form.start_year_2026_or_later?),
      (Form::Lettings::Pages::PersonSexRegisteredAtBirth.new(nil, nil, self, person_index:) if form.start_year_2026_or_later?),
      (Form::Lettings::Pages::PersonGenderSameAsSex.new(nil, nil, self, person_index:) if form.start_year_2026_or_later?),
      (Form::Lettings::Pages::PersonGenderIdentity.new(nil, nil, self, person_index:) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::NoFemalesPregnantHouseholdPersonValueCheck.new(nil, nil, self, person_index:) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdPersonValueCheck.new(nil, nil, self, person_index:) unless form.start_year_2026_or_later?),
      (Form::Lettings::Pages::NoHouseholdMemberLikelyToBePregnantCheck.new("no_household_member_likely_to_be_pregnant_person_#{person_index}_check", nil, self, person_index:) if form.start_year_2026_or_later?),
      Form::Lettings::Pages::PersonOverRetirementValueCheck.new("gender_#{person_index}_over_retirement_value_check", nil, self, person_index:),
      Form::Lettings::Pages::PersonWorkingSituation.new(nil, nil, self, person_index:),
      Form::Lettings::Pages::PersonUnderRetirementValueCheck.new("working_situation_#{person_index}_under_retirement_value_check", nil, self, person_index:),
      Form::Lettings::Pages::PersonOverRetirementValueCheck.new("working_situation_#{person_index}_over_retirement_value_check", nil, self, person_index:),
      (Form::Lettings::Pages::WorkingSituationIllnessCheckPerson.new("working_situation_#{person_index}_long_term_illness_check", nil, self, person_index:) if form.start_year_2026_or_later?),
    ]
  end

  def relationship_question(person_index:)
    if form.start_year_2025_or_later?
      Form::Lettings::Pages::PersonLeadPartner.new(nil, nil, self, person_index:)
    else
      Form::Lettings::Pages::PersonRelationshipToLead.new(nil, nil, self, person_index:)
    end
  end
end

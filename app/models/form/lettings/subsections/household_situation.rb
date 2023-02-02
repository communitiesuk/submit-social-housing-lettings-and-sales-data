class Form::Lettings::Subsections::HouseholdSituation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_situation"
    @label = "Household situation"
    @depends_on = [{ "non_location_setup_questions_completed?" => true }]
  end

  def pages
    @pages ||= [Form::Lettings::Pages::TimeLivedInLocalAuthority.new("time_lived_in_local_authority", nil, self),
                Form::Lettings::Pages::TimeOnWaitingList.new(nil, nil, self),
                Form::Lettings::Pages::ReasonForLeavingLastSettledHome.new(nil, nil, self),
                Form::Lettings::Pages::ReasonForLeavingLastSettledHomeRenewal.new(nil, nil, self),
                Form::Lettings::Pages::PreviousHousingSituation.new(nil, nil, self),
                Form::Lettings::Pages::PreviousHousingSituationRenewal.new(nil, nil, self),
                Form::Lettings::Pages::Homelessness.new("homelessness", nil, self),
                Form::Lettings::Pages::PreviousPostcode.new("previous_postcode", nil, self),
                Form::Lettings::Pages::PreviousLocalAuthority.new(nil, nil, self),
                Form::Lettings::Pages::ReasonablePreference.new("reasonable_preference", nil, self),
                Form::Lettings::Pages::ReasonablePreferenceReason.new(nil, nil, self),
                Form::Lettings::Pages::AllocationSystem.new("allocation_system", nil, self),
                Form::Lettings::Pages::Referral.new(nil, nil, self),
                Form::Lettings::Pages::ReferralPrp.new(nil, nil, self),
                Form::Lettings::Pages::ReferralSupportedHousing.new(nil, nil, self),
                Form::Lettings::Pages::ReferralSupportedHousingPrp.new(nil, nil, self)].compact
  end
end

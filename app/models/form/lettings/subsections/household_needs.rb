class Form::Lettings::Subsections::HouseholdNeeds < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_needs"
    @label = "Household needs"
    @depends_on = [{ "non_location_setup_questions_completed?" => true }]
  end

  def pages
    @pages ||= [Form::Lettings::Pages::ArmedForces.new("armed_forces", nil, self),
                Form::Lettings::Pages::ArmedForcesServing.new(nil, nil, self),
                Form::Lettings::Pages::ArmedForcesInjured.new(nil, nil, self),
                Form::Lettings::Pages::Pregnant.new("pregnant", nil, self),
                Form::Lettings::Pages::NoFemalesPregnantHouseholdValueCheck.new(nil, nil, self),
                Form::Lettings::Pages::FemalesInSoftAgeRangeInPregnantHouseholdValueCheck.new(nil, nil, self),
                Form::Lettings::Pages::AccessNeedsExist.new("access_needs_exist", nil, self),
                Form::Lettings::Pages::TypeOfAccessNeeds.new(nil, nil, self),
                Form::Lettings::Pages::HealthConditions.new("health_conditions", nil, self),
                Form::Lettings::Pages::HealthConditionEffects.new(nil, nil, self)].compact
  end
end

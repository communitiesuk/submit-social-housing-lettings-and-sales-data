class Form::Sales::Subsections::HouseholdNeeds < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_needs"
    @label = "Other household information"
  end

  def depends_on
    if form.start_year_2025_or_later?
      [{ "setup_completed?" => true, "is_staircase?" => true }]
    else
      [{ "setup_completed?" => true }]
    end
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::ArmedForces.new(nil, nil, self),
      Form::Sales::Pages::BuyerStillServing.new(nil, nil, self),
      Form::Sales::Pages::ArmedForcesSpouse.new(nil, nil, self),
      Form::Sales::Pages::HouseholdDisability.new(nil, nil, self),
      Form::Sales::Pages::HouseholdWheelchairCheck.new("disability_wheelchair_check", nil, self),
      Form::Sales::Pages::HouseholdWheelchair.new(nil, nil, self),
      Form::Sales::Pages::HouseholdWheelchairCheck.new("wheelchair_check", nil, self),
    ]
  end
end

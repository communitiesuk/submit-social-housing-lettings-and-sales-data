class Form::Sales::Subsections::HouseholdNeeds < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_needs"
    @label = "Household needs"
    @section = section
    @depends_on = [{ "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::HouseholdWheelchair.new(nil, nil, self),
      Form::Sales::Pages::HouseholdDisability.new(nil, nil, self),
      Form::Sales::Pages::HouseholdWheelchairCheck.new("wheelchair_check", nil, self),
    ]
  end
end

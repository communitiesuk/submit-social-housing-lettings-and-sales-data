class Form::Sales::Subsections::HouseholdNeeds < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_needs"
    @label = "Household needs"
    @section = section
    @depends_on = [{ "setup" => "completed" }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::HouseholdWheelchair.new(nil, nil, self),
    ]
  end
end

class Form::Sales::Pages::HouseholdWheelchair < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "household_wheelchair"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HouseholdWheelchair.new(nil, nil, self),
    ]
  end
end

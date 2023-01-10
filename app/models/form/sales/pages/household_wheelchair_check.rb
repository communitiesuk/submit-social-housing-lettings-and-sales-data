class Form::Sales::Pages::HouseholdWheelchairCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "wheelchair_when_not_disabled?" => true,
      },
    ]
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HouseholdWheelchairCheck.new(nil, nil, self),
    ]
  end
end

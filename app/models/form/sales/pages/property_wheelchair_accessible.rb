class Form::Sales::Pages::PropertyWheelchairAccessible < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_wheelchair_accessible"
    @depends_on = [
      { "form.start_year_2025_or_later?" => false },
      { "is_staircase?" => false },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyWheelchairAccessible.new(nil, nil, self),
    ]
  end
end

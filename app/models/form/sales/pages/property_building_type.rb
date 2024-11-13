class Form::Sales::Pages::PropertyBuildingType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_building_type"
    @depends_on = [
      { "form.start_year_2025_or_later?" => false },
      { "is_staircase?" => false },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyBuildingType.new(nil, nil, self),
    ]
  end
end

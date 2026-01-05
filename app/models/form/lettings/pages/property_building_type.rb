class Form::Lettings::Pages::PropertyBuildingType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_building_type"
    @depends_on = [
      { "is_general_needs?" => true, "form.start_year_2026_or_later?" => false },
    ]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Builtype.new(nil, nil, self)]
  end
end

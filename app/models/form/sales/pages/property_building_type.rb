class Form::Sales::Pages::PropertyBuildingType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_building_type"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyBuildingType.new(nil, nil, self),
    ]
  end
end

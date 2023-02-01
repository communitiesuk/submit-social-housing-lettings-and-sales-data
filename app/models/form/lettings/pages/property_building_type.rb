class Form::Lettings::Pages::PropertyBuildingType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_building_type"
    @header = ""
    @depends_on = [{ "needstype" => 1 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Builtype.new(nil, nil, self)]
  end
end

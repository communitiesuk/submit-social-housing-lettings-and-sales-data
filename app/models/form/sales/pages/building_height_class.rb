class Form::Sales::Pages::BuildingHeightClass < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "building_height_class"
    @copy_key = "sales.property_information.buildheightclass"
    @depends_on = [
      { "proptype" => 1 },
      { "proptype" => 2 },
      { "proptype" => 9 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuildingHeightClass.new(nil, nil, self),
    ]
  end
end

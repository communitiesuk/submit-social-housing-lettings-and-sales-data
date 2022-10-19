class Form::Sales::Subsections::PropertyInformation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "property_information"
    @label = "Property information"
    @section = section
    @depends_on = [{ "setup" => "completed" }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::PropertyNumberOfBedrooms.new(nil, nil, self),
      Form::Sales::Pages::PropertyBuildingType.new(nil, nil, self),
      Form::Sales::Pages::PropertyUnitType.new(nil, nil, self),
      Form::Sales::Pages::PropertyPostcode.new(nil, nil, self),
    ]
  end
end

class Form::Sales::Property::Subsections::PropertyInformation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "property_information"
    @label = "Property information"
    @section = section
    @depends_on = [{ "setup" => "completed" }]
  end

  def pages
    @pages ||= [
      Form::Sales::Property::Pages::PropertyNumberOfBedrooms.new(nil, nil, self),
    ]
  end
end

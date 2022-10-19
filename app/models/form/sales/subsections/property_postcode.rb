class Form::Sales::Subsections::PropertyPostcode < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "property_postcode"
    @label = "Property postcode"
    @section = section
    @depends_on = [{ "setup" => "completed" }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::PropertyPostcode.new(nil, nil, self),
    ]
  end
end

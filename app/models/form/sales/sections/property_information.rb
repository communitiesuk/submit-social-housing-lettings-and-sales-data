class Form::Sales::Sections::PropertyInformation < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "property_information"
    @label = "Property information"
    @description = ""
    @subsections = [Form::Sales::Subsections::PropertyInformation.new(nil, nil, self)] || []
  end
end

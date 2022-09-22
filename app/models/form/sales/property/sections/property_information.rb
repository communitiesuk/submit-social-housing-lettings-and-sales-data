class Form::Sales::Property::Sections::PropertyInformation < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "property_information"
    @label = "Property information"
    @description = ""
    @form = form
    @subsections = [Form::Sales::Property::Subsections::PropertyInformation.new(nil, nil, self)] || []
  end
end

class Form::Sales::Property::Pages::PropertyNumberOfBedrooms < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_number_of_bedrooms"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Property::Questions::PropertyNumberOfBedrooms.new(nil, nil, self),
    ]
  end
end

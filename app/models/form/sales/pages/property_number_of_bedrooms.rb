class Form::Sales::Pages::PropertyNumberOfBedrooms < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_number_of_bedrooms"
    @header = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyNumberOfBedrooms.new(nil, nil, self),
    ]
  end
end

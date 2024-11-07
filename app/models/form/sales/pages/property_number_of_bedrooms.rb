class Form::Sales::Pages::PropertyNumberOfBedrooms < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_number_of_bedrooms"
    @depends_on = [{"is_beds_inferred?" => false }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyNumberOfBedrooms.new(nil, nil, self),
    ]
  end
end

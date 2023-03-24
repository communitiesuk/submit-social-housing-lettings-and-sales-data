class Form::Lettings::Pages::PropertyNumberOfBedrooms < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_number_of_bedrooms"
    @depends_on = [{ "is_general_needs?" => true }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Beds.new(nil, nil, self)]
  end
end

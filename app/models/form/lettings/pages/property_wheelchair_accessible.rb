class Form::Lettings::Pages::PropertyWheelchairAccessible < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_wheelchair_accessible"
    @depends_on = [{ "is_supported_housing?" => false }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Wheelchair.new(nil, nil, self)]
  end
end

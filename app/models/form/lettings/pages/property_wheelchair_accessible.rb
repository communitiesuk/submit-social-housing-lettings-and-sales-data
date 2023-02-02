class Form::Lettings::Pages::PropertyWheelchairAccessible < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_wheelchair_accessible"
    @depends_on = [{ "needstype" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Wchair.new(nil, nil, self)]
  end
end

class Form::Sales::Pages::PropertyWheelchairAccessible < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_wheelchair_accessible"
    @header = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyWheelchairAccessible.new(nil, nil, self),
    ]
  end
end

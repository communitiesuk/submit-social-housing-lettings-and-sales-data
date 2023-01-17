class Form::Sales::Pages::Postcode < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_postcode"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PostcodeKnown.new(nil, nil, self),
      Form::Sales::Questions::Postcode.new(nil, nil, self),
    ]
  end
end

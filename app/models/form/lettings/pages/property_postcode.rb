class Form::Lettings::Pages::PropertyPostcode < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_postcode"
    @depends_on = [{ "is_general_needs?" => true }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::PostcodeKnown.new(nil, nil, self),
      Form::Lettings::Questions::PostcodeFull.new(nil, nil, self),
    ]
  end
end

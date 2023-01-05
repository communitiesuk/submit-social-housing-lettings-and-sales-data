class Form::Sales::Pages::LastAccommodation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "last_accommodation"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PreviousPostcodeKnown.new(nil, nil, self),
      Form::Sales::Questions::PreviousPostcode.new(nil, nil, self),
    ]
  end
end

class Form::Sales::Pages::Person1Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_1" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1AgeKnown.new(nil, nil, self),
      Form::Sales::Questions::Person1Age.new(nil, nil, self),
    ]
  end
end

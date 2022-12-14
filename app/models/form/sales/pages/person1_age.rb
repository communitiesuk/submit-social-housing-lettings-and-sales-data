class Form::Sales::Pages::Person1Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_1" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1AgeKnown.new("age2_known", nil, self),
      Form::Sales::Questions::Person1Age.new("age2", nil, self),
    ]
  end
end

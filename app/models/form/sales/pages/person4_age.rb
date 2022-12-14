class Form::Sales::Pages::Person4Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_4" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person4AgeKnown.new("age5_known", nil, self),
      Form::Sales::Questions::Person4Age.new("age5", nil, self),
    ]
  end
end

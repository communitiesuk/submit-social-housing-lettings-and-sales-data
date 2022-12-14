class Form::Sales::Pages::Person2Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_2" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person2AgeKnown.new("age3_known", nil, self),
      Form::Sales::Questions::Person2Age.new("age3", nil, self),
    ]
  end
end

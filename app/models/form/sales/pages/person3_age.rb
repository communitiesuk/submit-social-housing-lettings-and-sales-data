class Form::Sales::Pages::Person3Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_3" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person3AgeKnown.new("age4_known", nil, self),
      Form::Sales::Questions::Person3Age.new("age4", nil, self),
    ]
  end
end

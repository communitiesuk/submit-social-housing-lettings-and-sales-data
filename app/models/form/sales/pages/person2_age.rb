class Form::Sales::Pages::Person2Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 2 },
      { "hholdcount" => 3 },
      { "hholdcount" => 4 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person2AgeKnown.new(nil, nil, self),
      Form::Sales::Questions::Person2Age.new(nil, nil, self),
    ]
  end
end

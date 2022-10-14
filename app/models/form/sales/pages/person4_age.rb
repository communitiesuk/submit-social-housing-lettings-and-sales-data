class Form::Sales::Pages::Person4Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 4 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person4AgeKnown.new(nil, nil, self),
      Form::Sales::Questions::Person4Age.new(nil, nil, self),
    ]
  end
end

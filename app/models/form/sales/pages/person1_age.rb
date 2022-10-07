class Form::Sales::Pages::Person1Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 1 },
      { "hholdcount" => 2 },
      { "hholdcount" => 3 },
      { "hholdcount" => 4 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1AgeKnown.new(nil, nil, self),
      Form::Sales::Questions::Person1Age.new(nil, nil, self),
    ]
  end
end

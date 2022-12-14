class Form::Sales::Pages::Person3WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_working_situation"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_3" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person3WorkingSituation.new("ecstat4", nil, self),
    ]
  end
end

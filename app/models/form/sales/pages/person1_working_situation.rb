class Form::Sales::Pages::Person1WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_working_situation"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_1" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1WorkingSituation.new("ecstat2", nil, self),
    ]
  end
end

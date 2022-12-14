class Form::Sales::Pages::Person4WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_working_situation"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_4" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person4WorkingSituation.new("ecstat5", nil, self),
    ]
  end
end

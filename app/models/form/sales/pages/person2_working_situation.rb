class Form::Sales::Pages::Person2WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_working_situation"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_2" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person2WorkingSituation.new("ecstat3", nil, self),
    ]
  end
end

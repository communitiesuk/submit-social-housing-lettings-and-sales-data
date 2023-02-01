class Form::Lettings::Pages::Person8WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_8_working_situation"
    @header = ""
    @depends_on = [{ "details_known_8" => 0, "age8" => { "operator" => ">", "operand" => 15 } }, { "details_known_8" => 0, "age8" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Ecstat8.new(nil, nil, self)]
  end
end

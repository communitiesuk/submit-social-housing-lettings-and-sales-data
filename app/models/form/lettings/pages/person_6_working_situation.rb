class Form::Lettings::Pages::Person6WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_6_working_situation"
    @header = ""
    @depends_on = [{ "details_known_6" => 0, "age6" => { "operator" => ">", "operand" => 15 } }, { "details_known_6" => 0, "age6" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Ecstat6.new(nil, nil, self)]
  end
end

class Form::Lettings::Pages::Person7WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_7_working_situation"
    @header = ""
    @depends_on = [{ "details_known_7" => 0, "age7" => { "operator" => ">", "operand" => 15 } }, { "details_known_7" => 0, "age7" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Ecstat7.new(nil, nil, self)]
  end
end

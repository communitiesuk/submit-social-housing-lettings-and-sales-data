class Form::Lettings::Pages::Person4WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_working_situation"
    @header = ""
    @depends_on = [{ "details_known_4" => 0, "age4" => { "operator" => ">", "operand" => 15 } }, { "details_known_4" => 0, "age4" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Ecstat4.new(nil, nil, self)]
  end
end

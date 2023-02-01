class Form::Lettings::Pages::Person5WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_5_working_situation"
    @header = ""
    @depends_on = [{ "details_known_5" => 0, "age5" => { "operator" => ">", "operand" => 15 } }, { "details_known_5" => 0, "age5" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Ecstat5.new(nil, nil, self)]
  end
end

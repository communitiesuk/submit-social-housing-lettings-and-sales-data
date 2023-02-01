class Form::Lettings::Pages::Person3WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_working_situation"
    @header = ""
    @depends_on = [{ "details_known_3" => 0, "age3" => { "operator" => ">", "operand" => 15 } }, { "details_known_3" => 0, "age3" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Ecstat3.new(nil, nil, self)]
  end
end

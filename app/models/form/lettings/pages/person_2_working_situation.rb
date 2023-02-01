class Form::Lettings::Pages::Person2WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_working_situation"
    @header = ""
    @depends_on = [{ "details_known_2" => 0, "age2" => { "operator" => ">", "operand" => 15 } }, { "details_known_2" => 0, "age2" => nil }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Ecstat2.new(nil, nil, self)]
  end
end

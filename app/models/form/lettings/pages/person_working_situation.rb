class Form::Lettings::Pages::PersonWorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_working_situation"
    @header = ""
    @depends_on = [{ "details_known_#{person_index}" => 0, "age#{person_index}" => { "operator" => ">", "operand" => 15 } }, { "details_known_#{person_index}" => 0, "age#{person_index}" => nil }]
    @description = ""
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PersonWorkingSituation.new(nil, nil, self, person_index: @person_index)]
  end
end

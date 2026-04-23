class Form::Lettings::Pages::PersonKnown < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_known"
    @depends_on = depends_on
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::DetailsKnown.new(nil, nil, self, person_index: @person_index)]
  end

  def depends_on
    [{ "hhmemb" => {
      "operator" => ">=",
      "operand" => @person_index,
    } }]
  end
end

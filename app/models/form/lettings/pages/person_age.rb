class Form::Lettings::Pages::PersonAge < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_age"
    @header = ""
    @depends_on = [{ "details_known_#{person_index}" => 0 }]
    @description = ""
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::AgeKnown.new(nil, nil, self, person_index: @person_index), Form::Lettings::Questions::Age.new(nil, nil, self, person_index: @person_index)]
  end
end

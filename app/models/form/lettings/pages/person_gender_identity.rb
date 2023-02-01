class Form::Lettings::Pages::PersonGenderIdentity < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_gender_identity"
    @header = ""
    @depends_on = [{ "details_known_#{person_index}" => 0 }]
    @description = ""
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PersonGenderIdentity.new(nil, nil, self, person_index: @person_index)]
  end
end

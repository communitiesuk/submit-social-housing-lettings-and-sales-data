class Form::Lettings::Pages::PersonGenderSameAsSex < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_gender_same_as_sex"
    @person_index = person_index
    @depends_on = [
      { "details_known_#{person_index}" => 0 },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::GenderSameAsSex.new(nil, nil, self, person_index: @person_index),
      Form::Lettings::Questions::GenderDescription.new(nil, nil, self, person_index: @person_index),
    ]
  end
end

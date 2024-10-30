class Form::Lettings::Pages::PersonAge < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_age"
    @copy_key = "lettings.household_characteristics.age#{person_index}"
    @person_index = person_index
    @depends_on = [
      {
        "details_known_#{person_index}" => 0,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AgeKnown.new(nil, nil, self, person_index: @person_index),
      Form::Lettings::Questions::Age.new(nil, nil, self, person_index: @person_index),
    ]
  end
end

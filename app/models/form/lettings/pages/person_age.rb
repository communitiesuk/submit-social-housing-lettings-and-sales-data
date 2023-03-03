class Form::Lettings::Pages::PersonAge < ::Form::Page
  def initialize(id, hsh, subsection, person_index:, person_type: "non_child")
    super(id, hsh, subsection)
    @id = "person_#{person_index}_age_#{person_type}"
    @person_index = person_index
    @person_type = person_type
    @depends_on = [
      {
        "details_known_#{person_index}" => 0,
        "person_#{person_index}_child_relation?" => (person_type == "child"),
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AgeKnown.new(nil, nil, self, person_index: @person_index),
      Form::Lettings::Questions::Age.new(nil, nil, self, person_index: @person_index, person_type: @person_type),
    ]
  end
end

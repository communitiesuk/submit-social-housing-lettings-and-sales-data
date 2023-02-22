class Form::Lettings::Pages::PersonAge < ::Form::Page
  def initialize(id, hsh, subsection, person_index:, is_child:)
    super(id, hsh, subsection)
    @id = is_child ? "person_#{person_index}_age_child" : "person_#{person_index}_age_non_child"
    @person_index = person_index
    @is_child = is_child
    @depends_on = [
      {
        "details_known_#{person_index}" => 0,
        "person_#{person_index}_child_relation?" => is_child,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AgeKnown.new(nil, nil, self, person_index: @person_index),
      Form::Lettings::Questions::Age.new(nil, nil, self, person_index: @person_index, is_child: @is_child),
    ]
  end
end

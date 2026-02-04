# frozen_string_literal: true

class Form::Lettings::Pages::PersonSexRegisteredAtBirth < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_sex_registered_at_birth"
    @person_index = person_index
    @depends_on = [
      { "details_known_#{person_index}" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::PersonSexRegisteredAtBirth.new("sexrab#{@person_index}", nil, self, person_index: @person_index),
    ]
  end
end

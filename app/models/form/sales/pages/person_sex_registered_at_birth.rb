# frozen_string_literal: true

class Form::Sales::Pages::PersonSexRegisteredAtBirth < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @copy_key = "sales.household_characteristics.sex2.person" if person_index == 2
    @person_index = person_index
    @depends_on = [
      { "details_known_#{person_index}" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonSexRegisteredAtBirth.new("sexRAB#{@person_index}", nil, self, person_index: @person_index),
    ]
  end
end

class Form::Sales::Pages::PersonGenderSameAsSex < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @person_index = person_index
    @depends_on = [
      { "details_known_#{person_index}" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonGenderSameAsSex.new(nil, nil, self, person_index: @person_index),
      Form::Sales::Questions::PersonGenderDescription.new(nil, nil, self, person_index: @person_index),
    ]
  end
end

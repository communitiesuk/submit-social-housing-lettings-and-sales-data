class Form::Sales::Pages::PersonRelationshipToBuyer1 < ::Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @depends_on = [
      { "details_known_#{person_index}" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonRelationshipToBuyer1.new("relat#{@person_index}", nil, self, person_index: @person_index),
    ]
  end
end

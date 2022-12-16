class Form::Sales::Pages::PersonRelationshipToBuyer1 < ::Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { details_known_question_id => 1, "jointpur" => joint_purchase? ? 1 : 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonRelationshipToBuyer1.new(field_for_person("relat"), nil, self, person_index: @person_index),
    ]
  end
end

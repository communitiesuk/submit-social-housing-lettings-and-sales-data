class Form::Sales::Pages::PersonAge < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [{ details_known_question_id => 1, "jointpur" => joint_purchase? ? 1 : 2 }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonAgeKnown.new(field_for_person("age", "_known"), nil, self, person_index: @person_index),
      Form::Sales::Questions::PersonAge.new(field_for_person("age"), nil, self, person_index: @person_index),
    ]
  end
end

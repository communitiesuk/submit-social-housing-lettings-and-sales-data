class Form::Sales::Pages::PersonGenderIdentity < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @subsection = subsection
    @depends_on = [
      { details_known_question_id => 1, "jointpur" => joint_purchase? ? 1 : 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonGenderIdentity.new(field_for_person("sex"), nil, self, person_index: @person_index),
    ]
  end
end

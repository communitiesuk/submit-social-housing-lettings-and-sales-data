class Form::Sales::Pages::PersonAge < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = page_depends_on
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonAgeKnown.new(field_for_person("age", "_known"), nil, self, person_index: @person_index),
      Form::Sales::Questions::PersonAge.new(field_for_person("age"), nil, self, person_index: @person_index),
    ]
  end

  def page_depends_on
    return (person_display_number..4).map { |index| { "hholdcount" => index, "jointpur" => joint_purchase? ? 1 : 2 } } if person_display_number == 1

    [{ details_known_question_id => 1, "jointpur" => joint_purchase? ? 1 : 2 }]
  end
end

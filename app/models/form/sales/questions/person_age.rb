class Form::Sales::Questions::PersonAge < Form::Sales::Questions::Person
  def initialize(id, hsh, page, person_index:)
    super
    @check_answer_label = "Person #{person_display_number}’s age"
    @header = "Age"
    @type = "numeric"
    @width = 3
    @inferred_check_answers_value = {
      "condition" => { field_for_person("age", "_known") => 1 },
      "value" => "Not known",
    }
    @check_answers_card_number = person_index
  end
end

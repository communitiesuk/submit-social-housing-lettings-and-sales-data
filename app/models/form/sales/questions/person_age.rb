class Form::Sales::Questions::PersonAge < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person #{person_display_number(PERSON_INDEX)}’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = {
      "condition" => { "age#{person_database_number(PERSON_INDEX)}_known" => 1 },
      "value" => "Not known",
    }
    @check_answers_card_number = person_database_number(PERSON_INDEX)
  end

  PERSON_INDEX = {
    "age2" => 2,
    "age3" => 3,
    "age4" => 4,
    "age5" => 5,
    "age6" => 6,
  }.freeze
end

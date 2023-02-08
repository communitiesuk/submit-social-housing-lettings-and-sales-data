class Form::Sales::Questions::PersonAge < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @check_answer_label = "Person #{person_index}’s age"
    @header = "Age"
    @type = "numeric"
    @width = 3
    @inferred_check_answers_value = [{
      "condition" => { "age#{person_index}_known" => 1 },
      "value" => "Not known",
    }]
    @check_answers_card_number = person_index
    @min = 0
    @max = 110
  end
end

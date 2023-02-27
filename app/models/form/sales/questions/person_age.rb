class Form::Sales::Questions::PersonAge < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @check_answer_label = "Person #{person_index}’s age"
    @header = "#{question_number(person_index)} - Age"
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

  def question_number(person_index)
    case person_index
    when 2
      "Q37"
    when 3
      "Q41"
    when 4
      "Q45"
    when 5
      "Q49"
    when 6
      "Q53"
    end
  end
end

class Form::Sales::Questions::PersonAge < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @type = "numeric"
    @copy_key = "sales.household_characteristics.age2.person" if person_index == 2
    @width = 3
    @inferred_check_answers_value = [{
      "condition" => { "age#{person_index}_known" => 1 },
      "value" => "Not known",
    }]
    @check_answers_card_number = person_index
    @min = 0
    @max = 110
    @step = 1
    @person_index = person_index
    @question_number = question_number
  end

  def question_number
    base_question_number = case form.start_date.year
                           when 2023
                             29
                           else
                             31
                           end

    base_question_number + (4 * @person_index)
  end
end

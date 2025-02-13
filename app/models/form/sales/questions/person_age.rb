class Form::Sales::Questions::PersonAge < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @type = "numeric"
    @copy_key = person_index == 2 ? "sales.household_characteristics.age2.person.age2" : "sales.household_characteristics.age#{person_index}.age#{person_index}"
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

  BASE_QUESTION_NUMBERS = { 2023 => 29, 2024 => 31, 2025 => 29 }.freeze
  def question_number
    base_question_number = BASE_QUESTION_NUMBERS[form.start_date.year] || BASE_QUESTION_NUMBERS[BASE_QUESTION_NUMBERS.keys.max]

    base_question_number + (4 * @person_index)
  end
end

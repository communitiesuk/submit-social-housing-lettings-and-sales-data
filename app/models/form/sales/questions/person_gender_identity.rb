class Form::Sales::Questions::PersonGenderIdentity < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @type = "radio"
    @copy_key = "sales.household_characteristics.sex2.person" if person_index == 2
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = person_index
    @inferred_check_answers_value = [{
      "condition" => {
        id => "R",
      },
      "value" => "Prefers not to say",
    }]
    @person_index = person_index
    @question_number = question_number
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "X" => { "value" => "Non-binary" },
    "R" => { "value" => "Person prefers not to say" },
  }.freeze

  BASE_QUESTION_NUMBERS = { 2023 => 30, 2024 => 32, 2025 => 30 }.freeze
  def question_number
    base_question_number = BASE_QUESTION_NUMBERS[form.start_date.year] || BASE_QUESTION_NUMBERS[BASE_QUESTION_NUMBERS.keys.max]

    base_question_number + (4 * @person_index)
  end
end

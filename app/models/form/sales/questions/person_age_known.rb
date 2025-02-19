class Form::Sales::Questions::PersonAgeKnown < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @copy_key = person_index == 2 ? "sales.household_characteristics.age2.person.age2_known" : "sales.household_characteristics.age#{person_index}.age#{person_index}_known"
    @conditional_for = {
      "age#{person_index}" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age#{person_index}_known" => 0,
        },
        {
          "age#{person_index}_known" => 1,
        },
      ],
    }
    @check_answers_card_number = person_index
    @person_index = person_index
    @question_number = question_number
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  BASE_QUESTION_NUMBERS = { 2023 => 29, 2024 => 31, 2025 => 29 }.freeze
  def question_number
    base_question_number = BASE_QUESTION_NUMBERS[form.start_date.year] || BASE_QUESTION_NUMBERS[BASE_QUESTION_NUMBERS.keys.max]

    base_question_number + (4 * @person_index)
  end
end

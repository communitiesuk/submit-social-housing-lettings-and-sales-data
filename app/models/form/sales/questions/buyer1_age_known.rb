class Form::Sales::Questions::Buyer1AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age1_known"
    @type = "radio"
    @copy_key = "sales.household_characteristics.age1.age1_known"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "age1" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age1_known" => 0,
        },
        {
          "age1_known" => 1,
        },
        {
          "age1_known" => 2,
        },
      ],
    }
    @check_answers_card_number = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
    "2" => { "value" => "Buyer prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 20, 2024 => 22, 2025 => 20 }.freeze
end

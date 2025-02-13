class Form::Sales::Questions::PreviousPostcodeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ppcodenk"
    @copy_key = "sales.household_situation.last_accommodation.ppcodenk"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "ppostcode_full" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "ppcodenk" => 0,
        },
        {
          "ppcodenk" => 1,
        },
      ],
    }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 57, 2024 => 59, 2025 => 57 }.freeze
end

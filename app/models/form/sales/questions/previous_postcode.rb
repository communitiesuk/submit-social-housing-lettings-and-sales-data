class Form::Sales::Questions::PreviousPostcode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ppostcode_full"
    @copy_key = "sales.household_situation.last_accommodation.ppostcode_full"
    @type = "text"
    @width = 5
    @inferred_check_answers_value = [{
      "condition" => {
        "ppcodenk" => 1,
      },
      "value" => "Not known",
    }]
    @inferred_answers = {
      "prevloc" => {
        "is_previous_la_inferred" => true,
      },
    }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 57, 2024 => 59, 2025 => 57 }.freeze
end

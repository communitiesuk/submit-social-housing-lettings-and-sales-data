class Form::Lettings::Questions::PpostcodeFull < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ppostcode_full"
    @copy_key = "lettings.household_situation.previous_postcode.ppostcode_full"
    @type = "text"
    @width = 5
    @inferred_check_answers_value = [{
      "condition" => {
        "ppcodenk" => 1,
      },
      "value" => "Not known",
    }]
    @check_answers_card_number = 0
    @inferred_answers = { "prevloc" => { "is_previous_la_inferred" => true } }
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 80, 2024 => 79, 2025 => 79, 2026 => 86 }.freeze
end

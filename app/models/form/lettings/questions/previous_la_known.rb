class Form::Lettings::Questions::PreviousLaKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "previous_la_known"
    @copy_key = "lettings.household_situation.previous_local_authority.previous_la_known"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "prevloc" => [1] }
    @hidden_in_check_answers = { "depends_on" => [{ "previous_la_known" => 0 }, { "previous_la_known" => 1 }] }
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "0" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 81, 2024 => 80, 2025 => 80, 2026 => 87 }.freeze
end

class Form::Lettings::Questions::NationalityAllGroup < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "nationality_all_group"
    @copy_key = "lettings.household_characteristics.nationality_all.nationality_all_group"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @conditional_for = { "nationality_all" => [12] }
    @hidden_in_check_answers = { "depends_on" => [{ "nationality_all_group" => 12 }] }
  end

  ANSWER_OPTIONS = {
    "826" => { "value" => "United Kingdom" },
    "12" => { "value" => "Other" },
    "0" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 36, 2024 => 35, 2025 => 35, 2026 => 35 }.freeze
end

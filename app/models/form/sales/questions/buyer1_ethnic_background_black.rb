class Form::Sales::Questions::Buyer1EthnicBackgroundBlack < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @copy_key = "sales.household_characteristics.ethnic.ethnic_background_black"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "13" => { "value" => "African" },
    "12" => { "value" => "Caribbean" },
    "14" => { "value" => "Any other Black, African, Caribbean or Black British background" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 23, 2024 => 25, 2025 => 23, 2026 => 25 }.freeze
end

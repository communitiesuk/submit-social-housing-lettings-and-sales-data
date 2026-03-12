class Form::Sales::Questions::Buyer1EthnicBackgroundAsian < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @copy_key = "sales.household_characteristics.ethnic.ethnic_background_asian"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "10" => { "value" => "Bangladeshi" },
    "15" => { "value" => "Chinese" },
    "8" => { "value" => "Indian" },
    "9" => { "value" => "Pakistani" },
    "11" => { "value" => "Any other Asian or Asian British background" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 23, 2024 => 25, 2025 => 23, 2026 => 25 }.freeze
end

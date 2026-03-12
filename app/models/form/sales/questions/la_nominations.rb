class Form::Sales::Questions::LaNominations < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "lanomagr"
    @copy_key = "sales.sale_information.la_nominations"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 83, 2024 => 85, 2025 => 85, 2026 => 93 }.freeze
end

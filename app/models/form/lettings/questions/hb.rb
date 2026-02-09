class Form::Lettings::Questions::Hb < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hb"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Housing benefit" },
    "6" => { "value" => "Universal Credit housing element" },
    "9" => { "value" => "Neither" },
    "10" => { "value" => "Tenant prefers not to say" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 89, 2024 => 88, 2025 => 88, 2026 => 87 }.freeze
end

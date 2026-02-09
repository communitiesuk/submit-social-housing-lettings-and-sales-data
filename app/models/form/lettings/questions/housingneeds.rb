class Form::Lettings::Questions::Housingneeds < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "housingneeds"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 70, 2024 => 69, 2025 => 69, 2026 => 68 }.freeze
end

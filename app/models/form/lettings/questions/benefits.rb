class Form::Lettings::Questions::Benefits < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "benefits"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "All" },
    "2" => { "value" => "Some" },
    "3" => { "value" => "None" },
    "divider" => { "value" => true },
    "4" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 90, 2024 => 89, 2025 => 89, 2026 => 97 }.freeze
end

class Form::Lettings::Questions::Reasonpref < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reasonpref"
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 82, 2024 => 81, 2025 => 81, 2026 => 81 }.freeze
end

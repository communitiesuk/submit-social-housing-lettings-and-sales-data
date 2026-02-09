class Form::Lettings::Questions::Reservist < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reservist"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Person prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 68, 2024 => 67, 2025 => 67, 2026 => 74 }.freeze
end

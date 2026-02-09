class Form::Lettings::Questions::Homeless < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "homeless"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "11" => { "value" => "Yes - assessed by a local authority as homeless" },
    "1" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 79, 2024 => 78, 2025 => 78, 2026 => 85 }.freeze
end

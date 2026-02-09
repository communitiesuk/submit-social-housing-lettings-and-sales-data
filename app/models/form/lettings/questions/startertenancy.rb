class Form::Lettings::Questions::Startertenancy < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "startertenancy"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "2" => { "value" => "No" } }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 26, 2024 => 26, 2025 => 27, 2026 => 26 }.freeze
end

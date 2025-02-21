class Form::Lettings::Questions::Hbrentshortfall < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hbrentshortfall"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 99, 2024 => 98, 2025 => 96 }.freeze
end

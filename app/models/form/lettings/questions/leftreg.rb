class Form::Lettings::Questions::Leftreg < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "leftreg"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "6" => { "value" => "Yes" },
    "4" => { "value" => "No – they left up to and including 5 years ago" },
    "5" => { "value" => "No – they left more than 5 years ago" },
    "divider" => { "value" => true },
    "3" => { "value" => "Person prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 67, 2024 => 66, 2025 => 66, 2026 => 73 }.freeze
end

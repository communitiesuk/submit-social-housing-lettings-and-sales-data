class Form::Lettings::Questions::Wheelchair < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wchair"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 21, 2024 => 21, 2025 => 21, 2026 => 20 }.freeze
end

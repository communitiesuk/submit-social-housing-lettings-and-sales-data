class Form::Sales::Questions::PreviousBedrooms < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "frombeds"
    @type = "numeric"
    @width = 5
    @min = 1
    @max = 6
    @step = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 85, 2024 => 86, 2025 => 77, 2026 => 85 }.freeze
end

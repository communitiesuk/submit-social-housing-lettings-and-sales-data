class Form::Lettings::Questions::Beds < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "beds"
    @type = "numeric"
    @width = 2
    @max = 12
    @min = 1
    @step = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def derived?(log)
    log.is_bedsit?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 22, 2024 => 22, 2025 => 22, 2026 => 21 }.freeze
end

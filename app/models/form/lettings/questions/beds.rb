class Form::Lettings::Questions::Beds < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "beds"
    @type = "numeric"
    @width = 2
    @max = 12
    @min = 1
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  def derived?(log)
    log.is_bedsit?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 22, 2024 => 22, 2025 => 22, 2026 => 22 }.freeze
end

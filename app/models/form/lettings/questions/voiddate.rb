class Form::Lettings::Questions::Voiddate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "voiddate"
    @type = "date"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
    @top_guidance_partial = "void_date"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 23, 2024 => 23, 2025 => 23, 2026 => 22 }.freeze
end

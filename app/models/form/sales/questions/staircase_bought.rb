class Form::Sales::Questions::StaircaseBought < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "stairbought"
    @copy_key = "sales.sale_information.about_staircasing.stairbought"
    @type = "numeric"
    @width = 5
    @min = 0
    @max = 100
    @step = 0.1
    @suffix = "%"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @top_guidance_partial = "financial_calculations_shared_ownership"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 77, 2024 => 79, 2025 => 90, 2026 => 98 }.freeze
end

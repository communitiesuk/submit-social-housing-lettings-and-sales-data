class Form::Sales::Questions::MonthlyRentBeforeStaircasing < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mrentprestaircasing"
    @copy_key = "sales.sale_information.mrent_staircasing.prestaircasing"
    @type = "numeric"
    @min = 0
    @step = 0.01
    @width = 5
    @prefix = "£"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 100, 2026 => 108 }.freeze
end

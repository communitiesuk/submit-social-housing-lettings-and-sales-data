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
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 98 }.freeze
end

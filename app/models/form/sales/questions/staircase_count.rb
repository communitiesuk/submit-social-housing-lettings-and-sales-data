class Form::Sales::Questions::StaircaseCount < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "numstair"
    @copy_key = "sales.sale_information.stairprevious.numstair"
    @type = "numeric"
    @width = 2
    @min = 2
    @max = 10
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 82 }.freeze
end

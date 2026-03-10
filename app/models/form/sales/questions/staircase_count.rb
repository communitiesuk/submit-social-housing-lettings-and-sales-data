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
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 94, 2026 => 102 }.freeze
end

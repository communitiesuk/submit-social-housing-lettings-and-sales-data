class Form::Sales::Questions::PreviousBedrooms < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "frombeds"
    @copy_key = "sales.sale_information.frombeds"
    @type = "numeric"
    @width = 5
    @min = 1
    @max = 6
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 85, 2024 => 86 }.freeze
end

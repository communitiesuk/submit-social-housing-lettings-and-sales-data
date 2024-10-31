class Form::Sales::Questions::StaircaseBought < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "stairbought"
    @check_answer_label = "Percentage bought in this staircasing transaction"
    @header = "What percentage of the property has been bought in this staircasing transaction?"
    @type = "numeric"
    @width = 5
    @min = 0
    @max = 100
    @step = 0.1
    @suffix = "%"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @top_guidance_partial = "financial_calculations_shared_ownership"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 77, 2024 => 79 }.freeze
end

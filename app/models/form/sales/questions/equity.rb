class Form::Sales::Questions::Equity < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "equity"
    @check_answer_label = "Initial percentage equity stake"
    @header = "What was the initial percentage equity stake purchased?"
    @type = "numeric"
    @min = 0
    @max = 100
    @step = 0.1
    @width = 5
    @suffix = "%"
    @hint_text = "Enter the amount of initial equity held by the purchaser (for example, 25% or 50%)"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @top_guidance_partial = "financial_calculations_shared_ownership"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 89, 2024 => 90 }.freeze
end

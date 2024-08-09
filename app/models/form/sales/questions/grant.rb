class Form::Sales::Questions::Grant < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "grant"
    @check_answer_label = "Amount of any loan, grant or subsidy"
    @header = "What was the amount of any loan, grant, discount or subsidy given?"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @hint_text = "For all schemes except Right to Buy (RTB), Preserved Right to Buy (PRTB), Voluntary Right to Buy (VRTB) and Rent to Buy"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @top_guidance_partial = "financial_calculations_discounted_ownership"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 101, 2024 => 102 }.freeze
end

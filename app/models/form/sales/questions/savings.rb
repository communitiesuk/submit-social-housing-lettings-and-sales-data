class Form::Sales::Questions::Savings < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "savings"
    @copy_key = "sales.income_benefits_and_savings.savings.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}.savings"
    @type = "numeric"
    @width = 5
    @prefix = "£"
    @step = 10
    @min = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 72, 2024 => 74, 2025 => 71 }.freeze
end

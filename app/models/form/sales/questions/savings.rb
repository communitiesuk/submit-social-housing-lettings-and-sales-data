class Form::Sales::Questions::Savings < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "savings"
    @check_answer_label = "#{joint_purchase ? 'Buyers’' : 'Buyer’s'} total savings before any deposit paid"
    @header = "Enter their total savings to the nearest £10"
    @type = "numeric"
    @width = 5
    @prefix = "£"
    @step = 10
    @min = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 72, 2024 => 74 }.freeze
end

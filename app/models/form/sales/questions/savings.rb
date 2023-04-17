class Form::Sales::Questions::Savings < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "savings"
    @check_answer_label = "Buyer’s total savings before any deposit paid"
    @header = "Enter their total savings to the nearest £10"
    @type = "numeric"
    @width = 5
    @prefix = "£"
    @step = 10
    @min = 0
    @question_number = 72
  end
end

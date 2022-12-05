class Form::Sales::Questions::Savings < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "savings"
    @check_answer_label = "Buyer’s total savings (to nearest £10) before any deposit paid"
    @header = "Enter their total savings to the nearest £10"
    @type = "numeric"
    @page = page
    @width = 5
    @prefix = "£"
    @step = 1
    @min = 0
  end
end

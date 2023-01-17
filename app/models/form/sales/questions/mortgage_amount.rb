class Form::Sales::Questions::MortgageAmount < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mortgage"
    @check_answer_label = "Mortgage amount"
    @header = "What is the mortgage amount?"
    @type = "numeric"
    @min = 0
    @width = 5
    @prefix = "£"
  end
end

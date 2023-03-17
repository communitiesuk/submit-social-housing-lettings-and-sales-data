class Form::Sales::Questions::SaleDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "saledate"
    @check_answer_label = "Sale completion date"
    @header = "What is the sale completion date?"
    @type = "date"
    @question_number = 1
  end
end

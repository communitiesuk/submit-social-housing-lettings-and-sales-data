class Form::Sales::Setup::Questions::SaleDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "saledate"
    @check_answer_label = "Sale completion date"
    @header = "What is the sale completion date?"
    @type = "date"
    @page = page
  end
end

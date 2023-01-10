class Form::Sales::Questions::PurchasePrice < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "value"
    @check_answer_label = "Purchase price"
    @header = "What is the full purchase price?"
    @type = "numeric"
    @min = 0
    @width = 5
    @prefix = "£"
  end
end

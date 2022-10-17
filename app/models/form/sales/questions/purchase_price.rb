class Form::Sales::Questions::PurchasePrice < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "purchase_price"
    @check_answer_label = "Purchase price"
    @header = "What is the purchase price?"
    @hint_text = "This is how much the buyer paid for the actual sale price."
    @type = "text"
    @width = 10
    @page = page
  end
end

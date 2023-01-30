class Form::Sales::Questions::PurchasePriceDiscountedOwnership < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "value"
    @check_answer_label = "Purchase price"
    @header = "What is the full purchase price?"
    @type = "numeric"
    @min = 0
    @width = 5
    @prefix = "£"
    @hint_text = "For all schemes, including Right to Acquire (RTA), Right to Buy (RTB), Voluntary Right to Buy (VRTB) or Preserved Right to Buy (PRTB) sales, enter the full price of the property without any discount"
  end
end

class Form::Sales::Questions::Discount < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "discount"
    @check_answer_label = "Percentage discount"
    @header = "What was the percentage discount?"
    @type = "numeric"
    @page = page
    @min = 0
    @max = 100
    @width = 5
    @suffix = "%"
    @hint_text = "For Right to Buy (RTB), Preserved Right to Buy (PRTB), and Voluntary Right to Buy (VRTB)</br></br>
    If discount capped, enter capped %</br></br>
    If the property is being sold to an existing tenant under the RTB, PRTB, or VRTB schemes, enter the % discount from the full market value that is being given."
  end
end

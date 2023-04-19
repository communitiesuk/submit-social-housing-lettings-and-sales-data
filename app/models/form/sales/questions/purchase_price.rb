class Form::Sales::Questions::PurchasePrice < ::Form::Question
  def initialize(id, hsh, page, ownershipsch:)
    super(id, hsh, page)
    @id = "value"
    @check_answer_label = "Purchase price"
    @header = "What is the full purchase price?"
    @type = "numeric"
    @min = 0
    @width = 5
    @prefix = "£"
    @hint_text = hint_text
    @ownership_sch = ownershipsch
    @question_number = question_number
  end

  def question_number
    case @ownership_sch
    when 2 # discounted ownership scheme
      100
    when 3 # outright sale
      110
    end
  end

  def hint_text
    return if @ownership_sch == 3 # outright sale

    "For all schemes, including Right to Acquire (RTA), Right to Buy (RTB), Voluntary Right to Buy (VRTB) or Preserved Right to Buy (PRTB) sales, enter the full price of the property without any discount"
  end
end

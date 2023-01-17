class Form::Sales::Questions::DepositAmount < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "deposit"
    @check_answer_label = "Cash deposit"
    @header = "How much cash deposit was paid on the property?"
    @type = "numeric"
    @min = 0
    @width = 5
    @prefix = "£"
    @hint_text = "Enter the total cash sum paid by the buyer towards the property that was not funded by the mortgage"
    @derived = true
  end

  def selected_answer_option_is_derived?(_log)
    true
  end
end

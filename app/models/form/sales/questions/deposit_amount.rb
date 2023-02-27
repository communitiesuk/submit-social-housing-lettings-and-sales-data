class Form::Sales::Questions::DepositAmount < ::Form::Question
  def initialize(id, hsh, page, question_number:)
    super(id, hsh, page)
    @id = "deposit"
    @check_answer_label = "Cash deposit"
    @header = "#{question_number} - How much cash deposit was paid on the property?"
    @type = "numeric"
    @min = 0
    @width = 5
    @max = 999_999
    @prefix = "£"
    @hint_text = "Enter the total cash sum paid by the buyer towards the property that was not funded by the mortgage"
    @derived = true
  end

  def selected_answer_option_is_derived?(_log)
    true
  end
end

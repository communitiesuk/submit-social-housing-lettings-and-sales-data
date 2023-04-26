class Form::Sales::Questions::DepositAmount < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "deposit"
    @check_answer_label = "Cash deposit"
    @header = "How much cash deposit was paid on the property?"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @hint_text = "Enter the total cash sum paid by the buyer towards the property that was not funded by the mortgage"
    @derived = true
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  def selected_answer_option_is_derived?(_log)
    true
  end

  def question_number
    case @ownershipsch
    when 1
      95
    when 2
      108
    when 3
      116
    end
  end
end

class Form::Sales::Questions::MortgageAmount < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortgage"
    @check_answer_label = "Mortgage amount"
    @header = "What is the mortgage amount?"
    @type = "numeric"
    @min = 0
    @width = 5
    @prefix = "£"
    @hint_text = "Enter the amount of mortgage agreed with the mortgage lender. Exclude any deposits or cash payments. Numeric in pounds. Rounded to the nearest pound."
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  def question_number
    case @ownershipsch
    when 1
      91
    when 2
      104
    when 3
      112
    end
  end
end

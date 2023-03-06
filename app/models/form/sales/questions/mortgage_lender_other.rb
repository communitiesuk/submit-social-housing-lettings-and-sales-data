class Form::Sales::Questions::MortgageLenderOther < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortgagelenderother"
    @check_answer_label = "Other Mortgage Lender"
    @header = "What is the other mortgage lender?"
    @type = "text"
    @page = page
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  def question_number
    case @ownershipsch
    when 1
      92
    when 2
      105
    when 3
      113
    end
  end
end

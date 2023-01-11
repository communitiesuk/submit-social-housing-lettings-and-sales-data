class Form::Sales::Questions::MortgageLenderOther < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mortgagelenderother"
    @check_answer_label = "Other Mortgage Lender"
    @header = "What is the other mortgage lender?"
    @type = "text"
    @page = page
  end
end

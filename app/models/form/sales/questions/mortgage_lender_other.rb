class Form::Sales::Questions::MortgageLenderOther < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mortgagelenderother"
    @check_answer_label = "Mortgage Lender"
    @header = "Mortgage Lender"
    @type = "text"
    @page = page
  end
end

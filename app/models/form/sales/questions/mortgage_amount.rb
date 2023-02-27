class Form::Sales::Questions::MortgageAmount < ::Form::Question
  def initialize(id, hsh, page, question_number:)
    super(id, hsh, page)
    @id = "mortgage"
    @check_answer_label = "Mortgage amount"
    @header = "#{question_number} - What is the mortgage amount?"
    @type = "numeric"
    @min = 0
    @width = 5
    @prefix = "£"
    @hint_text = "Enter the amount of mortgage agreed with the mortgage lender. Exclude any deposits or cash payments. Numeric in pounds. Rounded to the nearest pound."
  end
end

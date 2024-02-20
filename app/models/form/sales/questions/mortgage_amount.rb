class Form::Sales::Questions::MortgageAmount < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortgage"
    @check_answer_label = "Mortgage amount"
    @header = "What is the mortgage amount?"
    @type = "numeric"
    @min = 1
    @step = 1
    @width = 5
    @prefix = "£"
    @hint_text = "Enter the amount of mortgage agreed with the mortgage lender. Exclude any deposits or cash payments. Numeric in pounds. Rounded to the nearest pound."
    @ownershipsch = ownershipsch
    @question_number = QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP[form.start_date.year][ownershipsch] if QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP[form.start_date.year].present?
  end

  QUESION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 91, 2 => 104, 3 => 112 },
    2024 => { 1 => 93, 2 => 106, 3 => 114 },
  }.freeze
end

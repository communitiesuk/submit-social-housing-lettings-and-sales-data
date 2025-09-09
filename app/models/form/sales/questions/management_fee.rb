class Form::Sales::Questions::ManagementFee < ::Form::Question
  def initialize(id, hsh, subsection)
    super
    @id = "management_fee"
    @copy_key = "sales.sale_information.management_fee.management_fee"
    @type = "numeric"
    @min = 1
    @step = 0.01
    @width = 5
    @prefix = "£"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 89 }.freeze
end

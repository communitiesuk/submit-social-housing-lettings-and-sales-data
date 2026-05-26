class Form::Sales::Questions::ManagementFee < ::Form::Question
  def initialize(id, hsh, subsection)
    super
    @id = "management_fee"
    @copy_key = "sales.sale_information.management_fee.management_fee"
    @type = "numeric"
    @min = 1
    @max = form.start_year_2025_or_later? ? 9_999 : nil
    @step = 0.01
    @width = 5
    @prefix = "£"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 89, 2026 => 97 }.freeze
end

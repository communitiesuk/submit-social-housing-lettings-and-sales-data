class Form::Sales::Questions::StaircaseLastDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "lasttransaction"
    @copy_key = "sales.sale_information.stairprevious.lasttransaction"
    @type = "date"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 95 }.freeze
end

class Form::Sales::Questions::StaircaseInitialDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "initialpurchase"
    @copy_key = "sales.sale_information.stairprevious.initialpurchase"
    @type = "date"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 96 }.freeze
end

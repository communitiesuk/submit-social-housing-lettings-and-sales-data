class Form::Sales::Questions::HandoverDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hodate"
    @copy_key = "sales.sale_information.handover_date"
    @type = "date"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 82, 2024 => 84 }.freeze
end

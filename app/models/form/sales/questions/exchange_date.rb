class Form::Sales::Questions::ExchangeDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "exdate"
    @copy_key = "sales.sale_information.exchange_date"
    @type = "date"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 81, 2024 => 83 }.freeze
end

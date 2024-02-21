class Form::Sales::Questions::ExchangeDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "exdate"
    @check_answer_label = "Exchange of contracts date"
    @header = "What is the exchange of contracts date?"
    @type = "date"
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 81, 2024 => 83 }.freeze
end

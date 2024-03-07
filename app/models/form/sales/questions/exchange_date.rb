class Form::Sales::Questions::ExchangeDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "exdate"
    @check_answer_label = "Exchange of contracts date"
    @header = "What is the exchange of contracts date?"
    @type = "date"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 81, 2024 => 83 }.freeze
end

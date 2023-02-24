class Form::Sales::Questions::ExchangeDate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "exdate"
    @check_answer_label = "Exchange of contracts date"
    @header = "Q81 - What is the exchange of contracts date?"
    @type = "date"
  end
end

class Form::Sales::Questions::OtherNationality1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "othernational"
    @check_answer_label = "Buyer 1’s nationality"
    @header = "Nationality"
    @type = "text"
    @check_answers_card_number = 1
  end
end

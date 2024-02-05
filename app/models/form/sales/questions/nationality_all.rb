class Form::Sales::Questions::NationalityAll < ::Form::Question
  def initialize(id, hsh, page, buyer_index)
    super(id, hsh, page)
    @check_answer_label = "Buyer #{buyer_index}’s nationality"
    @header = "Enter a nationality"
    @type = "select"
    @answer_options = GlobalConstants::COUNTRIES_ANSWER_OPTIONS
    @check_answers_card_number = buyer_index
    @question_number = buyer_index == 1 ? 24 : 32
  end

  def answer_label(log, _current_user = nil)
    answer_options[log.send(id).to_s]["name"]
  end
end

class Form::Sales::Questions::NationalityAll < ::Form::Question
  def initialize(id, hsh, page, buyer_index)
    super(id, hsh, page)
    @check_answer_label = "Buyer #{buyer_index}’s nationality"
    @header = "Enter a nationality"
    @type = "select"
    @answer_options = GlobalConstants::COUNTRIES_ANSWER_OPTIONS
    @check_answers_card_number = buyer_index
    @buyer_index = buyer_index
    @question_number = question_number
  end

  def answer_label(log, _current_user = nil)
    answer_options[log.send(id).to_s]["name"]
  end

  def question_number
    if form.start_date.year == 2023
      @buyer_index == 1 ? 24 : 32
    else
      @buyer_index == 1 ? 26 : 34
    end
  end

  def label_from_value(value)
    return unless value

    answer_options[value.to_s]["name"]
  end
end

class Form::Lettings::Questions::NationalityAll < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "nationality_all"
    @check_answer_label = "Lead tenant’s nationality"
    @header = "Enter a nationality"
    @type = "select"
    @check_answers_card_number = 1
    @answer_options = GlobalConstants::COUNTRIES_ANSWER_OPTIONS
    @question_number = 36
  end

  def answer_label(log, _current_user = nil)
    answer_options[log.nationality_all.to_s]["name"]
  end
end

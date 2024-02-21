class Form::Lettings::Questions::NationalityAll < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "nationality_all"
    @check_answer_label = "Lead tenant’s nationality"
    @header = "Enter a nationality"
    @type = "select"
    @check_answers_card_number = 1
    @answer_options = GlobalConstants::COUNTRIES_ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  def answer_label(log, _current_user = nil)
    answer_options[log.nationality_all.to_s]["name"]
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 36, 2024 => 35 }.freeze
end

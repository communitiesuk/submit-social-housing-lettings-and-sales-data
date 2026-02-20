class Form::Sales::Questions::GenderDescription2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "gender_description2"
    @type = "text"
    @check_answers_card_number = 2
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 0 }.freeze

  def derived?(log)
    log.gender_same_as_sex2 != 2
  end
end

class Form::Sales::Questions::PersonGenderDescription < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "gender_description#{person_index}"
    @type = "text"
    @check_answers_card_number = person_index
    @person_index = person_index
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 0 }.freeze

  def derived?(log)
    log.public_send("gender_same_as_sex#{@person_index}") != 2
  end
end

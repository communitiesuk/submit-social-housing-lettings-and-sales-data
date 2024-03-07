class Form::Lettings::Questions::Mrcdate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mrcdate"
    @check_answer_label = "Completion date of repairs"
    @header = "When were the repairs completed?"
    @type = "date"
    @check_answers_card_number = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 24 }.freeze
end

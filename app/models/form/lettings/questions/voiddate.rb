class Form::Lettings::Questions::Voiddate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "voiddate"
    @type = "date"
    @check_answers_card_number = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @top_guidance_partial = "void_date"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 23 }.freeze
end

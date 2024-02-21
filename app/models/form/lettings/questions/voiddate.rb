class Form::Lettings::Questions::Voiddate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "voiddate"
    @check_answer_label = "Void date"
    @header = "What is the void date?"
    @type = "date"
    @check_answers_card_number = 0
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
    @top_guidance_partial = "void_date"
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 23 }.freeze
end

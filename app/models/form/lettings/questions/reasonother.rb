class Form::Lettings::Questions::Reasonother < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reasonother"
    @check_answer_label = ""
    @header = "What is the reason?"
    @type = "text"
    @check_answers_card_number = 0
    @hint_text = ""
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 77, 2024 => 76 }.freeze
end

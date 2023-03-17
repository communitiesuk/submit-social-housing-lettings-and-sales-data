class Form::Lettings::Questions::Mrcdate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mrcdate"
    @check_answer_label = "Completion date of repairs"
    @header = "When were the repairs completed?"
    @type = "date"
    @check_answers_card_number = 0
    @hint_text = "For example, 27 3 2021."
    @question_number = 24
  end
end

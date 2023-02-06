class Form::Lettings::Questions::Reasonother < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reasonother"
    @check_answer_label = ""
    @header = "What is the reason?"
    @type = "text"
    @check_answers_card_number = 0
    @hint_text = ""
  end
end

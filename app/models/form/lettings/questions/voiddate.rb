class Form::Lettings::Questions::Voiddate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "voiddate"
    @check_answer_label = "Void or renewal date"
    @header = "What is the void or renewal date?"
    @type = "date"
    @check_answers_card_number = 0
    @hint_text = "For example, 27 3 2021."
  end
end

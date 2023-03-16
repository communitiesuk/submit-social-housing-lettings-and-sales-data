class Form::Lettings::Questions::Hhmemb < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hhmemb"
    @check_answer_label = "Number of household members"
    @header = "How many people live in the household for this letting?"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 8
    @min = 1
    @hint_text = "You can provide details for a maximum of 8 people."
    @step = 1
    @question_number = 31
  end
end

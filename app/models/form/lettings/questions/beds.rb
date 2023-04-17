class Form::Lettings::Questions::Beds < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "beds"
    @check_answer_label = "Number of bedrooms"
    @header = "How many bedrooms does the property have?"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 12
    @min = 1
    @hint_text = "If shared accommodation, enter the number of bedrooms occupied by this household. A bedsit has 1 bedroom."
    @step = 1
    @question_number = 22
  end
end

class Form::Lettings::Questions::Voiddate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "voiddate"
    @check_answer_label = "Void date"
    @header = "What is the void date?"
    @type = "date"
    @check_answers_card_number = 0
    @question_number = 23
    @guidance_partial = "void_date"
    @guidance_position = GuidancePosition::BOTTOM
  end
end

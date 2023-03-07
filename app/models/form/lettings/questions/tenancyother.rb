class Form::Lettings::Questions::Tenancyother < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancyother"
    @check_answer_label = ""
    @header = "Please state the tenancy type"
    @type = "text"
    @check_answers_card_number = 0
    @hint_text = ""
    @question_number = 27
  end
end

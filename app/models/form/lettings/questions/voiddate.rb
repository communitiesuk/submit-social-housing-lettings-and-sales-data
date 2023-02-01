class Form::Lettings::Questions::Voiddate < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "voiddate"
    @check_answer_label = "New-build handover date"
    @header = "What is the new-build handover date?"
    @type = "date"
    @check_answers_card_number = 0
    @hint_text = ""
  end
end

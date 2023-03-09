class Form::Lettings::Questions::OfferedSocialLet < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "offered"
    @check_answer_label = "Times previously offered since becoming available"
    @header = "How many times was the property offered between becoming vacant and this letting?"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 150
    @min = 0
    @hint_text = "Do not include the offer that led to this letting.This is after the last tenancy ended. If the property is being offered for let for the first time, enter 0."
    @step = 1
    @question_number = 18
  end
end

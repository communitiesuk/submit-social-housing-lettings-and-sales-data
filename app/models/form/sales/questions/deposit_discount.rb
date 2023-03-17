class Form::Sales::Questions::DepositDiscount < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "cashdis"
    @check_answer_label = "Cash discount through SocialHomeBuy"
    @header = "How much cash discount was given through Social HomeBuy?"
    @type = "numeric"
    @min = 0
    @max = 999_999
    @width = 5
    @prefix = "£"
    @hint_text = "Enter the total cash discount given on the property being purchased through the Social HomeBuy scheme"
    @question_number = 96
  end
end

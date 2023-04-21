class Form::Sales::Questions::Value < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "value"
    @check_answer_label = "Full purchase price"
    @header = "What was the full purchase price?"
    @type = "numeric"
    @min = 0
    @step = 1
    @width = 5
    @prefix = "£"
    @hint_text = "Enter the full purchase price of the property before any discounts are applied. For shared ownership, enter the full purchase price paid for 100% equity (this is equal to the value of the share owned by the PRP plus the value bought by the purchaser)"
    @question_number = 88
  end
end

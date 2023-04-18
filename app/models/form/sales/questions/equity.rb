class Form::Sales::Questions::Equity < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "equity"
    @check_answer_label = "Initial percentage equity stake"
    @header = "What was the initial percentage equity stake purchased?"
    @type = "numeric"
    @min = 0
    @max = 100
    @width = 5
    @suffix = "%"
    @hint_text = "Enter the amount of initial equity held by the purchaser (for example, 25% or 50%)"
    @question_number = 89
  end
end

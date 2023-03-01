class Form::Sales::Questions::MortgageLength < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mortlen"
    @check_answer_label = "Length of mortgage"
    @header = "What is the length of the mortgage?"
    @type = "numeric"
    @min = 0
    @max = 60
    @width = 5
    @suffix = " years"
    @hint_text = "You should round up to the nearest year. Value should not exceed 60 years."
  end
end

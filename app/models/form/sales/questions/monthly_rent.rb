class Form::Sales::Questions::MonthlyRent < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mrent"
    @check_answer_label = "Monthly rent"
    @header = "Q97 - What is the basic monthly rent?"
    @type = "numeric"
    @min = 0
    @width = 5
    @prefix = "£"
    @hint_text = "Amount paid before any charges"
  end
end

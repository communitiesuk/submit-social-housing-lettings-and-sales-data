class Form::Sales::Questions::MonthlyRent < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mrent"
    @check_answer_label = "Monthly rent"
    @header = "What is the basic monthly rent?"
    @type = "numeric"
    @min = 0
    @step = 0.01
    @width = 5
    @prefix = "£"
    @hint_text = "Amount paid before any charges"
    @question_number = QUESION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 97, 2024 => 99 }.freeze
end

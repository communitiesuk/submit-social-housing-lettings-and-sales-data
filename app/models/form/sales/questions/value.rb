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
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 88, 2024 => 90 }.freeze
end

class Form::Sales::Questions::PreviousBedrooms < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "frombeds"
    @check_answer_label = "Number of bedrooms in previous property"
    @header = "How many bedrooms did the property have?"
    @type = "numeric"
    @width = 5
    @min = 1
    @max = 6
    @step = 1
    @hint_text = "For bedsits enter 1"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 85, 2024 => 86 }.freeze
end

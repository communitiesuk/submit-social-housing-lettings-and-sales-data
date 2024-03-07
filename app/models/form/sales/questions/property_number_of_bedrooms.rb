class Form::Sales::Questions::PropertyNumberOfBedrooms < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "beds"
    @check_answer_label = "Number of bedrooms"
    @header = "How many bedrooms does the property have?"
    @hint_text = "A bedsit has 1 bedroom"
    @type = "numeric"
    @width = 2
    @min = 1
    @max = 9
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 11, 2024 => 18 }.freeze
end

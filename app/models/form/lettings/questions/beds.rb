class Form::Lettings::Questions::Beds < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "beds"
    @check_answer_label = "Number of bedrooms"
    @header = "How many bedrooms does the property have?"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 12
    @min = 1
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def derived?(log)
    log.is_bedsit?
  end

  def hint_text
    form.start_year_after_2024? ? "If shared accommodation, enter the number of bedrooms occupied by this household." : "If shared accommodation, enter the number of bedrooms occupied by this household. A bedsit has 1 bedroom."
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 22 }.freeze
end

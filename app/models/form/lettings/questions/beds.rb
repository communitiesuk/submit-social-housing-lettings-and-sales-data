class Form::Lettings::Questions::Beds < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "beds"
    @type = "numeric"
    @width = 2
    @max = 12
    @min = 1
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def derived?(log)
    log.is_bedsit?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 22 }.freeze
end

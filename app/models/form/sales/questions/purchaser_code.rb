class Form::Sales::Questions::PurchaserCode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "purchid"
    @type = "text"
    @width = 10
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 2, 2024 => 4 }.freeze
end

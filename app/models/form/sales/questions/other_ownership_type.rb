class Form::Sales::Questions::OtherOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "othtype"
    @check_answer_label = "Type of other sale"
    @header = "What type of sale is it?"
    @type = "text"
    @width = 10
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 6, 2024 => 8 }.freeze
end

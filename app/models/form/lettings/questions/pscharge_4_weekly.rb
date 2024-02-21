class Form::Lettings::Questions::Pscharge4Weekly < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "pscharge"
    @check_answer_label = "Personal service charge"
    @header = "What is the personal service charge?"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @hint_text = "For example, for heating or hot water. This doesn’t include housing benefit or Universal Credit."
    @step = 0.01
    @fields_to_add = %w[brent scharge pscharge supcharg]
    @result_field = "tcharge"
    @prefix = "£"
    @suffix = " every 4 weeks"
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 97, 2024 => 96 }.freeze
end

class Form::Lettings::Questions::TenancyLengthPeriodic < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancylength"
    @check_answer_label = "Length of periodic tenancy"
    @header = "What is the length of the periodic tenancy to the nearest year?"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 150
    @min = 0
    @step = 1
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
    @hint_text = "As this is a periodic tenancy, this question is optional. If you do not have the information available click save and continue"
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 28 }.freeze
end

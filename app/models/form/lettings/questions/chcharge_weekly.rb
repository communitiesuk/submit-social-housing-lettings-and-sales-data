class Form::Lettings::Questions::ChchargeWeekly < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "chcharge"
    @check_answer_label = "Care home charges"
    @header = "How much does the household pay every week?"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @hint_text = ""
    @step = 0.01
    @prefix = "£"
    @suffix = " every week"
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 94, 2024 => 93 }.freeze
end

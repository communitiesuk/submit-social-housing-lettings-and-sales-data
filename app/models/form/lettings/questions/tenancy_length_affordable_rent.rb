class Form::Lettings::Questions::TenancyLengthAffordableRent < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tenancylength"
    @check_answer_label = "Length of fixed-term tenancy"
    @header = "What is the length of the fixed-term tenancy to the nearest year?"
    @type = "numeric"
    @width = 2
    @check_answers_card_number = 0
    @max = 150
    @min = 0
    @step = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def hint_text
    if form.start_year_after_2024?
      "Do not include the starter or introductory period.</br>The minimum period is 2 years for social or affordable rent general needs logs. You do not need to submit CORE logs for these types of tenancies if they are shorter than 2 years."
    else
      "Do not include the starter or introductory period.</br>The minimum period is 2 years for social or affordable rent general needs logs and you do not need a log for shorter tenancies."
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 28 }.freeze
end

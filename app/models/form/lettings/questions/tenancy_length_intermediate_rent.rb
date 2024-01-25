class Form::Lettings::Questions::TenancyLengthIntermediateRent < ::Form::Question
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
    @question_number = 28
  end

  def hint_text
    if form.start_year_after_2024?
      "Do not include the starter or introductory period.</br>The minimum period is 1 year for intermediate rent general needs logs. You do not need to submit CORE logs for these types of tenancies if they are shorter than 1 year."
    else
      "Do not include the starter or introductory period.</br>The minimum period is 1 year for intermediate rent general needs logs and you do not need a log for shorter tenancies."
    end
  end
end

class Form::Lettings::Questions::Earnings < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "earnings"
    @check_answer_label = "Total household income"
    @header = "How much income does the household have in total?"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @guidance_partial = "what_counts_as_income"
    @hint_text = ""
    @step = 1
    @prefix = "£"
    @suffix = [
      { "label" => " every week", "depends_on" => { "incfreq" => 1 } },
      { "label" => " every month", "depends_on" => { "incfreq" => 2 } },
      { "label" => " every year", "depends_on" => { "incfreq" => 3 } },
    ]
    @question_number = 88
  end
end

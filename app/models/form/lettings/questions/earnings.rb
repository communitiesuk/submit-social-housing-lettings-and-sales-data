class Form::Lettings::Questions::Earnings < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "earnings"
    @copy_key = "lettings.income_and_benefits.income_amount.earnings"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @top_guidance_partial = "what_counts_as_income"
    @step = 0.01
    @prefix = "£"
    @suffix = [
      { "label" => " every week", "depends_on" => { "incfreq" => 1 } },
      { "label" => " every month", "depends_on" => { "incfreq" => 2 } },
      { "label" => " every year", "depends_on" => { "incfreq" => 3 } },
    ]
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 88, 2024 => 87, 2025 => 87, 2026 => 95 }.freeze
end

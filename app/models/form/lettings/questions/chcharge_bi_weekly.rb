class Form::Lettings::Questions::ChchargeBiWeekly < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "chcharge"
    @copy_key = "lettings.income_and_benefits.care_home.chcharge_bi_weekly"
    @type = "numeric"
    @width = 5
    @check_answers_card_number = 0
    @step = 0.01
    @prefix = "£"
    @suffix = " every 2 weeks"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 94, 2024 => 93, 2025 => 93, 2026 => 100 }.freeze
end

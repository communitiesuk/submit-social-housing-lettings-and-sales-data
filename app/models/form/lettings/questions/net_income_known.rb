class Form::Lettings::Questions::NetIncomeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "net_income_known"
    @check_answer_label = "Do you know the household’s combined total income after tax?"
    @header = "Do you know the household’s combined income after tax?"
    @type = "radio"
    @check_answers_card_number = 0
    @top_guidance_partial = "what_counts_as_income"
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
    "divider_a" => { "value" => true },
    "2" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 86, 2024 => 85 }.freeze
end

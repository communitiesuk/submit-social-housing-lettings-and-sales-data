class Form::Lettings::Questions::NetIncomeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "net_income_known"
    @type = "radio"
    @check_answers_card_number = 0
    @top_guidance_partial = "what_counts_as_income"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
    "divider_a" => { "value" => true },
    "2" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 86, 2024 => 85, 2025 => 85, 2026 => 93 }.freeze
end

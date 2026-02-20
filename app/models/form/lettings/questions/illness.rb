class Form::Lettings::Questions::Illness < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "illness"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 73, 2024 => 72, 2025 => 72, 2026 => 79 }.freeze
end

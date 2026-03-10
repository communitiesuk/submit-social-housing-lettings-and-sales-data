class Form::Sales::Questions::BuyerStillServing < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hhregresstill"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "4" => { "value" => "Yes" },
    "5" => { "value" => "No" },
    "6" => { "value" => "Buyer prefers not to say" },
    "divider" => { "value" => true },
    "7" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 63, 2024 => 65, 2025 => 62, 2026 => 70 }.freeze
end

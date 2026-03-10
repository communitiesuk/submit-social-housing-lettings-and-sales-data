class Form::Sales::Questions::PreviousTenureBuyer2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevtenbuy2"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Local authority tenant" },
    "2" => { "value" => "Private registered provider or housing association tenant" },
    "3" => { "value" => "Private tenant" },
    "5" => { "value" => "Owner occupier" },
    "4" => { "value" => "Tied home or renting with job" },
    "6" => { "value" => "Living with family or friends" },
    "7" => { "value" => "Temporary accommodation" },
    "9" => { "value" => "Other" },
    "divider" => { "value" => true },
    "0" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 61, 2024 => 63, 2025 => 60, 2026 => 68 }.freeze
end

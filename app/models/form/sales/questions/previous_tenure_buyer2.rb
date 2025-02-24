class Form::Sales::Questions::PreviousTenureBuyer2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevtenbuy2"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
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
    "0" => { "value" => "Don't know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 61, 2024 => 63, 2025 => 60 }.freeze
end

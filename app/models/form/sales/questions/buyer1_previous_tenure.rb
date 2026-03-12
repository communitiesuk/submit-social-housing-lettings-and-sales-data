class Form::Sales::Questions::Buyer1PreviousTenure < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevten"
    @type = "radio"
    @answer_options = answer_options
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def answer_options
    {
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
    }
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 56, 2024 => 58, 2025 => 56, 2026 => 64 }.freeze
end

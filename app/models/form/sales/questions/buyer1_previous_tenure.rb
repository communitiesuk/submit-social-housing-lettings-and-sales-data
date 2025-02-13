class Form::Sales::Questions::Buyer1PreviousTenure < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevten"
    @type = "radio"
    @answer_options = answer_options
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
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
      "0" => { "value" => "Don’t know" },
    }
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 56, 2024 => 58, 2025 => 56 }.freeze
end

class Form::Sales::Questions::BuyersOrganisations < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buyers_organisations"
    @type = "checkbox"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "pregyrha" => { "value" => "Their private registered provider (PRP) - housing association" },
    "pregother" => { "value" => "Other private registered provider (PRP) - housing association" },
    "pregla" => { "value" => "Local Authority" },
    "pregghb" => { "value" => "Help to Buy Agent" },
    "pregblank" => { "value" => "None of the above" },
  }.freeze

  def displayed_answer_options(_log, _user = nil)
    {
      "pregyrha" => { "value" => "Their private registered provider (PRP) - housing association" },
      "pregother" => { "value" => "Other private registered provider (PRP) - housing association" },
      "pregla" => { "value" => "Local Authority" },
      "pregghb" => { "value" => "Help to Buy Agent" },
    }
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 59, 2024 => 61 }.freeze
end

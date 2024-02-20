class Form::Sales::Questions::BuyersOrganisations < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buyers_organisations"
    @check_answer_label = "Organisations buyers were registered with"
    @header = "What organisations were the buyers registered with?"
    @type = "checkbox"
    @hint_text = "Select all that apply. This question is optional. If no options are applicable, leave the options blank, and select save and continue."
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR[form.start_date.year]
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

  def unanswered_error_message
    "At least one option must be selected of these four"
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 59, 2024 => 61 }.freeze
end

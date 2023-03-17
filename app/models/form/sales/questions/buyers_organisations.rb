class Form::Sales::Questions::BuyersOrganisations < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buyers_organisations"
    @check_answer_label = "Organisations buyers were registered with"
    @header = "What organisations were the buyers registered with?"
    @type = "checkbox"
    @hint_text = "Select all that apply"
    @answer_options = ANSWER_OPTIONS
    @question_number = 59
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
end

class Form::Sales::Questions::PreviousTenureBuyer2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevtenbuy2"
    @check_answer_label = "Buyer 2’s previous tenure"
    @header = "What was buyer 2’s previous tenure?"
    @type = "radio"
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 61
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
end

class Form::Sales::Questions::Buyer1PreviousTenure < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevten"
    @check_answer_label = "Buyer 1’s previous tenure"
    @header = "What was buyer 1’s previous tenure?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Local Authority" },
    "2" => { "value" => "Private registered provider or housing association tenant" },
    "3" => { "value" => "Private tenant" },
    "5" => { "value" => "Owner occupier" },
    "4" => { "value" => "Tied home or renting with job" },
    "6" => { "value" => "Living with family or friends" },
    "7" => { "value" => "Temporary accomodation" },
    "9" => { "value" => "Other" },
    "0" => { "value" => "Don’t know" },
  }.freeze

  def displayed_answer_options(_log, _user = nil)
    {
      "1" => { "value" => "Local Authority" },
      "2" => { "value" => "Private registered provider or housing association tenant" },
      "3" => { "value" => "Private tenant" },
      "5" => { "value" => "Owner occupier" },
      "4" => { "value" => "Tied home or renting with job" },
      "6" => { "value" => "Living with family or friends" },
      "7" => { "value" => "Temporary accomodation" },
      "9" => { "value" => "Other" },
    }
  end
end

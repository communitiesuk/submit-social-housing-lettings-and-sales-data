class Form::Sales::Questions::HousingBenefits < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hb"
    @check_answer_label = "Housing-related benefits buyer received before buying this property"
    @header = "Was the buyer receiving any of these housing-related benefits immediately before buying this property?"
    @type = "radio"
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Housing benefit" },
    "3" => { "value" => "Universal Credit housing element" },
    "divider" => { "value" => true },
    "1" => { "value" => "Neither housing benefit or Universal Credit housing element" },
    "4" => { "value" => "Don’t know " },
  }.freeze
end

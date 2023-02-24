class Form::Sales::Questions::Fromprop < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "fromprop"
    @check_answer_label = "Previous property type"
    @header = "Q86 - What was the previous property type?"
    @type = "radio"
    @hint_text = ""
    @page = page
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Flat or maisonette" },
    "2" => { "value" => "Bedsit" },
    "3" => { "value" => "House" },
    "4" => { "value" => "Bungalow" },
    "9" => { "value" => "Other" },
  }.freeze
end

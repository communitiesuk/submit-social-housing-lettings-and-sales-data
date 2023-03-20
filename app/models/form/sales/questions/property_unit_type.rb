class Form::Sales::Questions::PropertyUnitType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "proptype"
    @check_answer_label = "Type of unit"
    @header = "What type of unit is the property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = 12
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Flat or maisonette" },
    "2" => { "value" => "Bedsit" },
    "3" => { "value" => "House" },
    "4" => { "value" => "Bungalow" },
    "9" => { "value" => "Other" },
  }.freeze
end

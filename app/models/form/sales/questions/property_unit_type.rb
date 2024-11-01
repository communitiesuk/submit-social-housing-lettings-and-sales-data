class Form::Sales::Questions::PropertyUnitType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "proptype"
    @copy_key = "sales.property_information.proptype"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Flat or maisonette" },
    "2" => { "value" => "Bedsit" },
    "3" => { "value" => "House" },
    "4" => { "value" => "Bungalow" },
    "9" => { "value" => "Other" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 12, 2024 => 19 }.freeze
end

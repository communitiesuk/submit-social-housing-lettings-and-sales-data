class Form::Sales::Questions::Fromprop < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "fromprop"
    @copy_key = "sales.sale_information.fromprop"
    @type = "radio"
    @page = page
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Flat or maisonette" },
    "2" => { "value" => "Bedsit" },
    "3" => { "value" => "House" },
    "4" => { "value" => "Bungalow" },
    "9" => { "value" => "Other" },
    "0" => { "value" => "Don’t know" },
  }.freeze

  def displayed_answer_options(_log, _user = nil)
    {
      "1" => { "value" => "Flat or maisonette" },
      "2" => { "value" => "Bedsit" },
      "3" => { "value" => "House" },
      "4" => { "value" => "Bungalow" },
      "9" => { "value" => "Other" },
    }
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 86, 2024 => 87 }.freeze
end

class Form::Sales::Questions::Fromprop < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "fromprop"
    @type = "radio"
    @page = page
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 86, 2024 => 87, 2025 => 78, 2026 => 86 }.freeze
end

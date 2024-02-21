class Form::Sales::Questions::Fromprop < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "fromprop"
    @check_answer_label = "Previous property type"
    @header = "What was the previous property type?"
    @type = "radio"
    @hint_text = ""
    @page = page
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
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

  QUESION_NUMBER_FROM_YEAR = { 2023 => 86, 2024 => 88 }.freeze
end

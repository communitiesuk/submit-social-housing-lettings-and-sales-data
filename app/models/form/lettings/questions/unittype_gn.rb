class Form::Lettings::Questions::UnittypeGn < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "unittype_gn"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Bedsit" },
    "8" => { "value" => "Bungalow" },
    "1" => { "value" => "Flat or maisonette" },
    "7" => { "value" => "House" },
    "10" => { "value" => "Shared bungalow" },
    "4" => { "value" => "Shared flat or maisonette" },
    "9" => { "value" => "Shared house" },
    "6" => { "value" => "Other" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 19, 2024 => 19, 2025 => 19, 2026 => 19 }.freeze
end

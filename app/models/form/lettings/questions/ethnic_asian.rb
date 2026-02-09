class Form::Lettings::Questions::EthnicAsian < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @copy_key = "lettings.household_characteristics.ethnic.ethnic_background_asian"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "10" => {
      "value" => "Bangladeshi",
    },
    "15" => {
      "value" => "Chinese",
    },
    "8" => {
      "value" => "Indian",
    },
    "9" => {
      "value" => "Pakistani",
    },
    "11" => {
      "value" => "Any other Asian or Asian British background",
    },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 35, 2024 => 34, 2025 => 34, 2026 => 34 }.freeze
end

class Form::Lettings::Questions::EthnicMixed < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @copy_key = "lettings.household_characteristics.ethnic.ethnic_background_mixed"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "4" => {
      "value" => "White and Black Caribbean",
    },
    "5" => {
      "value" => "White and Black African",
    },
    "6" => {
      "value" => "White and Asian",
    },
    "7" => {
      "value" => "Any other Mixed or Multiple ethnic background",
    },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 35, 2024 => 34, 2025 => 34, 2026 => 34 }.freeze
end

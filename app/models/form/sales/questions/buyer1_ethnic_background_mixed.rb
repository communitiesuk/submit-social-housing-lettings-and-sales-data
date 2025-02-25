class Form::Sales::Questions::Buyer1EthnicBackgroundMixed < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @copy_key = "sales.household_characteristics.ethnic.ethnic_background_mixed"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "4" => { "value" => "White and Black Caribbean" },
    "5" => { "value" => "White and Black African" },
    "6" => { "value" => "White and Asian" },
    "7" => { "value" => "Any other Mixed or Multiple ethnic background" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 23, 2024 => 25, 2025 => 23 }.freeze
end

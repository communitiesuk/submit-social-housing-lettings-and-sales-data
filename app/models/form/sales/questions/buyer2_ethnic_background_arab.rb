class Form::Sales::Questions::Buyer2EthnicBackgroundArab < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnicbuy2"
    @copy_key = "sales.household_characteristics.ethnicbuy2.ethnic_background_arab"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "19" => { "value" => "Arab" },
    "16" => { "value" => "Other ethnic group" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 31, 2024 => 33, 2025 => 31 }.freeze
end

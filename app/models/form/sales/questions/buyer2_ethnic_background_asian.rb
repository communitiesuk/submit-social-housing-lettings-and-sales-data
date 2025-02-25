class Form::Sales::Questions::Buyer2EthnicBackgroundAsian < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnicbuy2"
    @copy_key = "sales.household_characteristics.ethnicbuy2.ethnic_background_asian"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "10" => { "value" => "Bangladeshi" },
    "15" => { "value" => "Chinese" },
    "8" => { "value" => "Indian" },
    "9" => { "value" => "Pakistani" },
    "11" => { "value" => "Any other Asian or Asian British background" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 31, 2024 => 33, 2025 => 31 }.freeze
end

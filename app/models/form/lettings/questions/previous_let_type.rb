class Form::Lettings::Questions::PreviousLetType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "unitletas"
    @type = "radio"
    @check_answers_card_number = 0
    @answer_options = form.start_year_2024_or_later? ? ANSWER_OPTIONS_AFTER_2024 : ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Social rent basis" },
    "2" => { "value" => "Affordable rent basis" },
    "5" => { "value" => "A London Affordable Rent basis" },
    "6" => { "value" => "A Rent to Buy basis" },
    "7" => { "value" => "A London Living Rent basis" },
    "8" => { "value" => "Another Intermediate Rent basis" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  ANSWER_OPTIONS_AFTER_2024 = {
    "1" => { "value" => "Social rent basis" },
    "2" => { "value" => "Affordable rent basis" },
    "5" => { "value" => "London Affordable Rent basis" },
    "6" => { "value" => "Rent to Buy basis" },
    "7" => { "value" => "London Living Rent basis" },
    "8" => { "value" => "Another Intermediate Rent basis" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 16, 2024 => 17 }.freeze
end

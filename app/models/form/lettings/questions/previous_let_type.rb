class Form::Lettings::Questions::PreviousLetType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "unitletas"
    @check_answer_label = "Most recent let type"
    @header = "What type was the property most recently let as?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = form.start_year_after_2024? ? "This is the rent type of the previous tenancy in this property." : ""
    @answer_options = form.start_year_after_2024? ? ANSWER_OPTIONS_AFTER_2024 : ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
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

  QUESION_NUMBER_FROM_YEAR = { 2023 => 16, 2024 => 17 }.freeze
end

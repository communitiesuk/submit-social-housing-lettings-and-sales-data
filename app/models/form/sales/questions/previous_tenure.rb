class Form::Sales::Questions::PreviousTenure < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "socprevten"
    @type = "radio"
    @page = page
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Social Rent" },
    "2" => { "value" => "Affordable Rent" },
    "3" => { "value" => "London Affordable Rent" },
    "9" => { "value" => "Other" },
    "10" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 87, 2024 => 88 }.freeze
end

class Form::Sales::Questions::PreviousTenure < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "socprevten"
    @check_answer_label = "Previous property tenure"
    @header = "What was the previous tenure of the buyer?"
    @type = "radio"
    @hint_text = ""
    @page = page
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Social Rent" },
    "2" => { "value" => "Affordable Rent" },
    "3" => { "value" => "London Affordable Rent" },
    "9" => { "value" => "Other" },
    "10" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 87, 2024 => 89 }.freeze
end

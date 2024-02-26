class Form::Sales::Questions::HouseholdWheelchair < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wheel"
    @header = "Does anyone in the household use a wheelchair?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "This can be inside or outside the home"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 66, 2024 => 68 }.freeze
end

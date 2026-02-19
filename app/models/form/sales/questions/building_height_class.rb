class Form::Sales::Questions::BuildingHeightClass < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buildheightclass"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "High-rise" },
    "2" => { "value" => "Low-rise" },
    "3" => { "value" => "Don't know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 17 }.freeze
end

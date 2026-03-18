class Form::Sales::Questions::BuildingHeightClass < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buildheightclass"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "High-rise" },
    "2" => { "value" => "Low-rise" },
    "3" => { "value" => "Don't know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 17 }.freeze
end

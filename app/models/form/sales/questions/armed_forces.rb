class Form::Sales::Questions::ArmedForces < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hhregres"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "7" => { "value" => "No" },
    "3" => { "value" => "Buyer prefers not to say" },
    "divider" => { "value" => true },
    "8" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 62, 2024 => 64, 2025 => 61 }.freeze
end

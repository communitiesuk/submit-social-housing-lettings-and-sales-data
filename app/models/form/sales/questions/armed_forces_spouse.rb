class Form::Sales::Questions::ArmedForcesSpouse < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "armedforcesspouse"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "4" => { "value" => "Yes" },
    "5" => { "value" => "No" },
    "6" => { "value" => "Buyer prefers not to say" },
    "7" => { "value" => "Don't know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 64, 2024 => 66, 2025 => 63 }.freeze
end

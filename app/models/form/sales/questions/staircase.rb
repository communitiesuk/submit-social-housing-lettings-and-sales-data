class Form::Sales::Questions::Staircase < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "staircase"
    @copy_key = form.start_year_2025_or_later? ? "sales.setup.staircasing" : "sales.sale_information.staircasing"
    @type = "radio"
    @answer_options = form.start_year_2025_or_later? ? ANSWER_OPTIONS.except("3") : ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 76, 2024 => 78, 2025 => 7 }.freeze
end

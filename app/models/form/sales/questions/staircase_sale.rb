class Form::Sales::Questions::StaircaseSale < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "staircasesale"
    @copy_key = form.start_year_2025_or_later? ? "sales.sale_information.staircasesale" : "sales.sale_information.about_staircasing.staircasesale"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 79, 2024 => 81 }.freeze
end

class Form::Sales::Questions::StaircaseSale < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "staircasesale"
    @copy_key = form.start_year_2025_or_later? ? "sales.sale_information.staircasesale" : "sales.sale_information.about_staircasing.staircasesale"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 79, 2024 => 81, 2025 => 92, 2026 => 100 }.freeze
end

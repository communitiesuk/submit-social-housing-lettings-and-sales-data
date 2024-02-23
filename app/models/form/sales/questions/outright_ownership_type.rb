class Form::Sales::Questions::OutrightOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "type"
    @check_answer_label = "Type of outright sale"
    @header = "What is the type of outright sale?"
    @type = "radio"
    @top_guidance_partial = guidance_partial
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "othtype" => [12],
    }
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "10" => { "value" => "Outright" },
    "12" => { "value" => "Other sale" },
  }.freeze

  def guidance_partial
    "outright_sale_type_definitions" if form.start_date.year >= 2023
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 6, 2024 => 8 }.freeze
end

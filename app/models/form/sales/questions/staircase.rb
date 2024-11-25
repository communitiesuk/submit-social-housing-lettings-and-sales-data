class Form::Sales::Questions::Staircase < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "staircase"
    @copy_key = "sales.#{page.subsection.copy_key}.staircasing"
    @type = "radio"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def answer_options
    if form.start_year_2025_or_later?
      {
        "1" => { "value" => "Yes" },
        "2" => { "value" => "No" },
      }.freeze
    else
      {
        "1" => { "value" => "Yes" },
        "2" => { "value" => "No" },
        "3" => { "value" => "Don’t know" },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 76, 2024 => 78 }.freeze
end

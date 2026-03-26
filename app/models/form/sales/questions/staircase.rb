class Form::Sales::Questions::Staircase < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "staircase"
    @copy_key = "sales.#{page.subsection.copy_key}.staircasing"
    @type = "radio"
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
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
        "divider" => { "value" => true },
        "3" => { "value" => "Don’t know" },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 76, 2024 => 78, 2025 => 7, 2026 => 7 }.freeze
end

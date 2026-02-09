class Form::Lettings::Questions::Sheltered < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sheltered"
    @type = "radio"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  def answer_options
    if form.start_year_2025_or_later?
      {
        "7" => { "value" => "Yes – for tenants with low support needs" },
        "2" => { "value" => "Yes – extra care housing" },
        "8" => { "value" => "Yes – other" },
        "3" => { "value" => "No" },
        "divider" => { "value" => true },
        "4" => { "value" => "Don’t know" },
      }
    else
      { "1" => { "value" => "Yes – specialist retirement housing" },
        "2" => { "value" => "Yes – extra care housing" },
        "5" => { "value" => "Yes – sheltered housing for adults aged under 55 years" },
        "6" => { "value" => "Yes – sheltered housing for adults aged 55 years and over who are not retired" },
        "3" => { "value" => "No" },
        "divider" => { "value" => true },
        "4" => { "value" => "Don’t know" } }
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 29, 2024 => 29, 2025 => 25, 2026 => 24 }.freeze
end

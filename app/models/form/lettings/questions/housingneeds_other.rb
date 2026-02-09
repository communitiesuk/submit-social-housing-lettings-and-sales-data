class Form::Lettings::Questions::HousingneedsOther < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "housingneeds_other"
    @copy_key = "lettings.household_needs.housingneeds_type.housingneeds_other"
    @type = "radio"
    @check_answers_card_number = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  def answer_options
    if form.start_year_2024_or_later?
      {
        "1" => { "value" => "Yes" },
        "0" => { "value" => "No" },
        "divider" => { "value" => true },
        "2" => { "value" => "Don’t know" },
      }.freeze
    else
      {
        "1" => { "value" => "Yes" },
        "0" => { "value" => "No" },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 72, 2024 => 71, 2025 => 71, 2026 => 71 }.freeze
end

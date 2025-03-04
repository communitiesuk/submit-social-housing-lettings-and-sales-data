class Form::Lettings::Questions::FirstTimePropertyLetAsSocialHousing < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "first_time_property_let_as_social_housing"
    @type = "radio"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def answer_options
    {
      "1" => { "value" => "Yes", "hint" => yes_hint },
      "0" => { "value" => "No", "hint" => no_hint },
    }.freeze
  end

  def yes_hint
    form.start_year_2024_or_later? ? "This property was previously used for other purposes or is a new-build." : "This is a new let."
  end

  def no_hint
    form.start_year_2024_or_later? ? "This is a re-let of existing social housing stock." : "This is a re-let of existing social housing."
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 14, 2024 => 15, 2025 => 12 }.freeze
end

class Form::Lettings::Questions::EthnicWhite < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @copy_key = "lettings.household_characteristics.ethnic.ethnic_background_white"
    @type = "radio"
    @check_answers_card_number = 1
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def answer_options
    if form.start_year_2024_or_later?
      {
        "1" => { "value" => "English, Welsh, Northern Irish, Scottish or British" },
        "2" => { "value" => "Irish" },
        "18" => { "value" => "Gypsy or Irish Traveller" },
        "20" => { "value" => "Roma" },
        "3" => { "value" => "Any other White background" },
      }.freeze
    else
      {
        "1" => { "value" => "English, Welsh, Northern Irish, Scottish or British" },
        "2" => { "value" => "Irish" },
        "18" => { "value" => "Gypsy or Irish Traveller" },
        "3" => { "value" => "Any other White background" },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 35, 2024 => 34, 2025 => 34, 2026 => 34 }.freeze
end

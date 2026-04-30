class Form::Sales::Questions::Buyer2EthnicBackgroundWhite < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnicbuy2"
    @copy_key = "sales.household_characteristics.ethnicbuy2.ethnic_background_white"
    @type = "radio"
    @check_answers_card_number = 2
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def answer_options
    {
      "1" => { "value" => "English, Welsh, Northern Irish, Scottish or British" },
      "2" => { "value" => "Irish" },
      "18" => { "value" => "Gypsy or Irish Traveller" },
      "20" => { "value" => "Roma" },
      "3" => { "value" => "Any other White background" },
    }.freeze
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 31, 2024 => 33, 2025 => 31, 2026 => 34 }.freeze
end

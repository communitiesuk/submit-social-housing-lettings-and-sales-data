class Form::Sales::Questions::PropertyWheelchairAccessible < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wchair"
    @copy_key = "sales.property_information.wchair"
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 17, 2024 => 21, 2025 => 19, 2026 => 20 }.freeze
end

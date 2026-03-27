class Form::Sales::Questions::GenderIdentity2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sex2"
    @type = "radio"
    @copy_key = "sales.household_characteristics.sex2.buyer"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "X" => { "value" => "Non-binary" },
    "R" => { "value" => "Buyer prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 29, 2024 => 31, 2025 => 29, 2026 => 31 }.freeze

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "R"

    super
  end
end

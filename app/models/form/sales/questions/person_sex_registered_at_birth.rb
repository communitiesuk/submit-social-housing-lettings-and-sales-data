class Form::Sales::Questions::PersonSexRegisteredAtBirth < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @type = "radio"
    @copy_key = "sales.household_characteristics.sexrab2.person" if person_index == 2
    @check_answers_card_number = person_index
    @answer_options = ANSWER_OPTIONS
    @person_index = person_index
    @question_number = get_person_question_number(BASE_QUESTION_NUMBERS)
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "divider" => { "value" => true },
    "R" => { "value" => "Person prefers not to say" },
  }.freeze

  BASE_QUESTION_NUMBERS = { 2023 => 30, 2024 => 32, 2025 => 31 }.freeze

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "R"

    super
  end
end

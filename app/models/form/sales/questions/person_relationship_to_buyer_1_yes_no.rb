class Form::Sales::Questions::PersonRelationshipToBuyer1YesNo < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @type = "radio"
    @copy_key = "sales.household_characteristics.relat2.person" if person_index == 2
    @answer_options = {
      "P" => { "value" => "Yes" },
      "X" => { "value" => "No" },
      "R" => { "value" => "Person prefers not to say" },
    }
    @check_answers_card_number = person_index
    @person_index = person_index
    @question_number = get_person_question_number(BASE_QUESTION_NUMBERS)
  end

  BASE_QUESTION_NUMBERS = { 2025 => 28, 2026 => 29 }.freeze

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "R"

    super
  end
end

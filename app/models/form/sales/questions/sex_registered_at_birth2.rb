class Form::Sales::Questions::SexRegisteredAtBirth2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sexrab2"
    @type = "radio"
    @copy_key = "sales.household_characteristics.sexrab2.buyer"
    @check_answers_card_number = 2
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "divider" => { "value" => true },
    "R" => { "value" => "Buyer prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 0 }.freeze

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "R"

    super
  end
end

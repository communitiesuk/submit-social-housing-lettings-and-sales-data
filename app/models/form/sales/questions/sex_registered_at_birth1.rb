class Form::Sales::Questions::SexRegisteredAtBirth1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sexrab1"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "divider" => { "value" => true },
    "R" => { "value" => "Buyer prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 22 }.freeze

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "R"

    super
  end
end

class Form::Sales::Questions::Buyer2RelationshipToBuyer1YesNo < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "relat2"
    @copy_key = "sales.household_characteristics.relat2.buyer"
    @type = "radio"
    @answer_options = {
      "P" => { "value" => "Yes" },
      "X" => { "value" => "No" },
      "R" => { "value" => "Buyer prefers not to say" },
    }
    @check_answers_card_number = 2
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 27, 2026 => 29 }.freeze

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "R"
    #check for when ans opt is already prefers not to say
    super
  end
end

class Form::Sales::Questions::Buyer2RelationshipToBuyer1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "relat2"
    @copy_key = "sales.household_characteristics.relat2.buyer"
    @type = "radio"
    @answer_options = answer_options
    @check_answers_card_number = 2
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def answer_options
    if form.start_year_2024_or_later?
      {
        "P" => { "value" => "Partner" },
        "C" => { "value" => "Child" },
        "X" => { "value" => "Other" },
        "R" => { "value" => "Buyer prefers not to say" },
      }
    else
      {
        "P" => { "value" => "Partner" },
        "C" => { "value" => "Child", "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education." },
        "X" => { "value" => "Other" },
        "R" => { "value" => "Buyer prefers not to say" },
      }
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 27, 2024 => 29, 2025 => 27, 2026 => 29 }.freeze

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == "R"

    super
  end
end

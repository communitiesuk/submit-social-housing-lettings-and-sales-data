class Form::Sales::Questions::Buyer2RelationshipToBuyer1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "relat2"
    @copy_key = "sales.household_characteristics.relat2.buyer"
    @type = "radio"
    @answer_options = answer_options
    @check_answers_card_number = 2
    @inferred_check_answers_value = [{
      "condition" => {
        "relat2" => "R",
      },
      "value" => "Prefers not to say",
    }]
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def answer_options
    {
      "P" => { "value" => "Partner" },
      "C" => { "value" => "Child" },
      "X" => { "value" => "Other" },
      "R" => { "value" => "Buyer prefers not to say" },
    }
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 27, 2024 => 29, 2025 => 27, 2026 => 29 }.freeze
end

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
    @inferred_check_answers_value = [{
      "condition" => {
        "relat2" => "R",
      },
      "value" => "Prefers not to say",
    }]
    @check_answers_card_number = 2
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 27 }.freeze
end

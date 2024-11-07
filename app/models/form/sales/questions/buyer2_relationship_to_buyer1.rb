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
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 27, 2024 => 29 }.freeze
end

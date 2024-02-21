class Form::Sales::Questions::Buyer2RelationshipToBuyer1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "relat2"
    @check_answer_label = "Buyer 2's relationship to buyer 1"
    @header = "What is buyer 2's relationship to buyer 1?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @inferred_check_answers_value = [{
      "condition" => {
        "relat2" => "R",
      },
      "value" => "Prefers not to say",
    }]
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "P" => { "value" => "Partner" },
    "C" => { "value" => "Child", "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education." },
    "X" => { "value" => "Other" },
    "R" => { "value" => "Buyer prefers not to say" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 27, 2024 => 29 }.freeze
end

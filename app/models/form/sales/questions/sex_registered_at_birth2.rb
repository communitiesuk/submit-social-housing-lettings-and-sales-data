# frozen_string_literal: true

class Form::Sales::Questions::SexRegisteredAtBirth2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sexRAB2"
    @type = "radio"
    @copy_key = "sales.household_characteristics.sexRAB2.buyer"
    @check_answers_card_number = 2
    @inferred_check_answers_value = [{
      "condition" => {
        "sex2" => "R",
      },
      "value" => "Prefers not to say",
    }]
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
end

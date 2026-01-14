# frozen_string_literal: true

class Form::Sales::Questions::SexRegisteredAtBirth1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sexRAB1"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "divider" => { "value" => true },
    "R" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 32 }.freeze
end

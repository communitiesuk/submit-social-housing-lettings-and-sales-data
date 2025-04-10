class Form::Sales::Questions::Buyer1EthnicGroup < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic_group"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 1
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "White" },
    "1" => { "value" => "Mixed or Multiple ethnic groups" },
    "2" => { "value" => "Asian or Asian British" },
    "3" => { "value" => "Black, African, Caribbean or Black British" },
    "4" => { "value" => "Arab or other ethnic group" },
    "divider" => { "value" => true },
    "17" => { "value" => "Buyer prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 22, 2024 => 24, 2025 => 22 }.freeze
end

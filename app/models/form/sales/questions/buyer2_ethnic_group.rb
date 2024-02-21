class Form::Sales::Questions::Buyer2EthnicGroup < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic_group2"
    @check_answer_label = "Buyer 2’s ethnic group"
    @header = "What is buyer 2’s ethnic group?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
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

  QUESION_NUMBER_FROM_YEAR = { 2023 => 30, 2024 => 32 }.freeze
end

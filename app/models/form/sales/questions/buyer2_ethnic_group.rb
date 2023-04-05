class Form::Sales::Questions::Buyer2EthnicGroup < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic_group2"
    @check_answer_label = "Buyer 2’s ethnic group"
    @header = "What is buyer 2’s ethnic group?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @inferred_check_answers_value = [{
      "condition" => {
        "ethnic_group2" => 17,
      },
      "value" => "Prefers not to say",
    }]
    @check_answers_card_number = 2
    @question_number = 30
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "White" },
    "1" => { "value" => "Mixed or Multiple ethnic groups" },
    "2" => { "value" => "Asian or Asian British" },
    "3" => { "value" => "Black, African, Caribbean or Black British" },
    "4" => { "value" => "Arab or other ethnic group" },
    "divider" => { "value" => true },
    "17" => { "value" => "Buyer 2 prefers not to say" },
  }.freeze
end

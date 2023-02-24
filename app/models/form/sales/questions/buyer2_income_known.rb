class Form::Sales::Questions::Buyer2IncomeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income2nk"
    @check_answer_label = "Buyer 2’s gross annual income"
    @header = "Q69 - Do you know buyer 2’s annual income?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "income2" => [0],
    }
    @check_answers_card_number = 2
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end

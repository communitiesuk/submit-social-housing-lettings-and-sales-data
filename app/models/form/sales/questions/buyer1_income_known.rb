class Form::Sales::Questions::Buyer1IncomeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income1nk"
    @check_answer_label = "Buyer 1’s gross annual income"
    @header = "Q67 - Do you know buyer 1’s annual income?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "income1" => [0],
    }
    @check_answers_card_number = 1
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end

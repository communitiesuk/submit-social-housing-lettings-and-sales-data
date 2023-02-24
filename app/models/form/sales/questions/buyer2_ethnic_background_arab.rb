class Form::Sales::Questions::Buyer2EthnicBackgroundArab < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnicbuy2"
    @check_answer_label = "Buyer 2’s ethnic background"
    @header = "Q31 - Which of the following best describes the buyer 2’s Arab background?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
  end

  ANSWER_OPTIONS = {
    "19" => { "value" => "Arab" },
    "16" => { "value" => "Other ethnic group" },
  }.freeze
end

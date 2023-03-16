class Form::Sales::Questions::Buyer2EthnicBackgroundMixed < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnicbuy2"
    @check_answer_label = "Buyer 2’s ethnic background"
    @header = "Which of the following best describes buyer 2’s Mixed or Multiple ethnic groups background?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = 31
  end

  ANSWER_OPTIONS = {
    "4" => { "value" => "White and Black Caribbean" },
    "5" => { "value" => "White and Black African" },
    "6" => { "value" => "White and Asian" },
    "7" => { "value" => "Any other Mixed or Multiple ethnic background" },
  }.freeze
end

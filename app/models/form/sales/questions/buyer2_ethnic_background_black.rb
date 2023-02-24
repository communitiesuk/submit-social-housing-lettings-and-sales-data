class Form::Sales::Questions::Buyer2EthnicBackgroundBlack < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnicbuy2"
    @check_answer_label = "Buyer 2’s ethnic background"
    @header = "Q31 - Which of the following best describes the buyer 2’s Black, African, Caribbean or Black British background?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
  end

  ANSWER_OPTIONS = {
    "13" => { "value" => "African" },
    "12" => { "value" => "Caribbean" },
    "14" => { "value" => "Any other Black, African or Caribbean background" },
  }.freeze
end

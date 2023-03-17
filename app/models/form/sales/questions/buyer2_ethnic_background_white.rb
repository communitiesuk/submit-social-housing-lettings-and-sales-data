class Form::Sales::Questions::Buyer2EthnicBackgroundWhite < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnicbuy2"
    @check_answer_label = "Buyer 2’s ethnic background"
    @header = "Which of the following best describes buyer 2’s White background?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = 31
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "English, Welsh, Northern Irish, Scottish or British" },
    "2" => { "value" => "Irish" },
    "18" => { "value" => "Gypsy or Irish Traveller" },
    "3" => { "value" => "Any other White background" },
  }.freeze
end

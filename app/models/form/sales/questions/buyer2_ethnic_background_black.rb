class Form::Sales::Questions::Buyer2EthnicBackgroundBlack < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnicbuy2"
    @check_answer_label = "Buyer 2’s ethnic background"
    @header = "Which of the following best describes buyer 2’s Black, African, Caribbean or Black British background?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = QUESION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "13" => { "value" => "African" },
    "12" => { "value" => "Caribbean" },
    "14" => { "value" => "Any other Black, African, Caribbean or Black British background" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 31, 2024 => 33 }.freeze
end

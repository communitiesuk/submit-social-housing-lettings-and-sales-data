class Form::Sales::Questions::Buyer2EthnicBackgroundAsian < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnicbuy2"
    @check_answer_label = "Buyer 2’s ethnic background"
    @header = "Which of the following best describes buyer 2’s Asian or Asian British background?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "10" => { "value" => "Bangladeshi" },
    "15" => { "value" => "Chinese" },
    "8" => { "value" => "Indian" },
    "9" => { "value" => "Pakistani" },
    "11" => { "value" => "Any other Asian or Asian British background" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 31, 2024 => 33 }.freeze
end

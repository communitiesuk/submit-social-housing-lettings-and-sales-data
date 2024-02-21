class Form::Sales::Questions::Buyer2LiveInProperty < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buy2livein"
    @check_answer_label = "Will buyer 2 live in the property?"
    @header = "Will buyer 2 live in the property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 34, 2024 => 36 }.freeze
end

class Form::Sales::Questions::StaircaseSale < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "staircasesale"
    @check_answer_label = "Part of a back-to-back staircasing transaction"
    @header = "Is this transaction part of a back-to-back staircasing transaction to facilitate sale of the home on the open market?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 79, 2024 => 81 }.freeze
end

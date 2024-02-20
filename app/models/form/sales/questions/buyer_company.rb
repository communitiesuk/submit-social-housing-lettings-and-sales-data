class Form::Sales::Questions::BuyerCompany < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "companybuy"
    @check_answer_label = "Company buyer"
    @header = "Is the buyer a company?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 7, 2024 => 9 }.freeze
end

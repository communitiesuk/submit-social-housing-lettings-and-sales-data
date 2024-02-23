class Form::Sales::Questions::BuyerCompany < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "companybuy"
    @check_answer_label = "Company buyer"
    @header = "Is the buyer a company?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 7, 2024 => 9 }.freeze
end

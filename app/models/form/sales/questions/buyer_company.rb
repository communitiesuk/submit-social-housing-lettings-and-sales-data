class Form::Sales::Questions::BuyerCompany < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "companybuy"
    @check_answer_label = "Company buyer"
    @header = "Is the buyer a company?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = 7
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end

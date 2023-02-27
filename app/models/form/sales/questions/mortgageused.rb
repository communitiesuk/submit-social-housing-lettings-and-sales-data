class Form::Sales::Questions::Mortgageused < ::Form::Question
  def initialize(id, hsh, page, question_number:)
    super(id, hsh, page)
    @id = "mortgageused"
    @check_answer_label = "Mortgage used"
    @header = "#{question_number} - Was a mortgage used for the purchase of this property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end

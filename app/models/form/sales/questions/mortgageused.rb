class Form::Sales::Questions::Mortgageused < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortgageused"
    @check_answer_label = "Mortgage used"
    @header = "Was a mortgage used for the purchase of this property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze

  def displayed_answer_options(_log, _user = nil)
    {
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No" },
    }
  end

  def question_number
    case @ownershipsch
    when 1
      90
    when 2
      103
    when 3
      111
    end
  end
end

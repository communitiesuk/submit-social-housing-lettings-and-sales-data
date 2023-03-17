class Form::Sales::Questions::ExtraBorrowing < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "extrabor"
    @check_answer_label = "Any other borrowing?"
    @header = "Does this include any extra borrowing?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze

  def question_number
    case @ownershipsch
    when 1
      94
    when 2
      107
    when 3
      115
    end
  end
end

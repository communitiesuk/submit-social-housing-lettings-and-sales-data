class Form::Sales::Questions::MortgageLength < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mortlen"
    @check_answer_label = "Length of mortgage"
    @header = "What is the length of the mortgage?"
    @type = "numeric"
    @min = 0
    @max = 60
    @width = 5
    @suffix = " years"
    @hint_text = "You should round up to the nearest year. Value should not exceed 60 years."
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  def question_number
    case @ownershipsch
    when 1
      93
    when 2
      106
    when 3
      114
    end
  end
end

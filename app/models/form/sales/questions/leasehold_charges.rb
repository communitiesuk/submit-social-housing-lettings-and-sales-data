class Form::Sales::Questions::LeaseholdCharges < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mscharge"
    @check_answer_label = "Monthly leasehold charges"
    @header = "Enter the total monthly charge"
    @type = "numeric"
    @min = 1
    @step = 0.01
    @width = 5
    @prefix = "£"
    @ownershipsch = ownershipsch
    @question_number = question_number
  end

  def question_number
    case @ownershipsch
    when 1
      98
    when 2
      109
    when 3
      117
    end
  end
end

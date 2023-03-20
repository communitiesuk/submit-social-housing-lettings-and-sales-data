class Form::Sales::Questions::LeaseholdCharges < ::Form::Question
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @id = "mscharge"
    @check_answer_label = "Monthly leasehold charges"
    @header = "Enter the total monthly charge"
    @type = "numeric"
<<<<<<< HEAD
    @min = 1
=======
    @min = 0
    @step = 0.01
>>>>>>> a59c771e (add or alter step on numeric questions in sales, amend one test given step changes)
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

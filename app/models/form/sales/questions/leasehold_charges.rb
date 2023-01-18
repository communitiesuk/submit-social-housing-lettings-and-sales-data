class Form::Sales::Questions::LeaseholdCharges < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mscharge"
    @check_answer_label = "Monthly leasehold charges"
    @header = "Enter the total monthly charge"
    @type = "numeric"
    @min = 0
    @width = 5
    @prefix = "£"
  end
end

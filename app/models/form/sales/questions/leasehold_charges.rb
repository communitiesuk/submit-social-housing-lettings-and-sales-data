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
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP.max_by { |k, _v| k }.last)[ownershipsch]
  end

  QUESTION_NUMBER_FROM_YEAR_AND_OWNERSHIP = {
    2023 => { 1 => 98, 2 => 109, 3 => 117 },
    2024 => { 1 => 100, 2 => 111, 3 => 118 },
  }.freeze
end

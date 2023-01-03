class Form::Sales::Questions::LeaseholdCharges < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "mscharge"
    @check_answer_label = "Monthly rent"
    @header = "Enter the total monthly charge"
    @type = "numeric"
    @page = page
    @width = 2
    @prefix = "£"
    @inferred_check_answers_value = {
      "condition" => {
        "mscharge_known" => 0,
      },
      "value" => 0,
    }
  end
end

class Form::Sales::Questions::ManagementFee < ::Form::Question
  def initialize(id, hsh, subsection)
    super
    @id = "management_fee"
    @copy_key = "sales.sale_information.management_fee.management_fee"
    @type = "numeric"
    @min = 1
    @step = 0.01
    @width = 5
    @prefix = "£"
  end
end

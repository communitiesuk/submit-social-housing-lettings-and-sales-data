class Form::Sales::Pages::EstateManagementFee < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @copy_key = "sales.sale_information.management_fee"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HasManagementFee.new(nil, nil, self),
      Form::Sales::Questions::ManagementFee.new(nil, nil, self),
    ]
  end
end

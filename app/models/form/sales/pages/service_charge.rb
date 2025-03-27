class Form::Sales::Pages::ServiceCharge < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @copy_key = "sales.sale_information.servicecharges"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HasServiceCharge.new(nil, nil, self),
      Form::Sales::Questions::ServiceCharge.new(nil, nil, self),
    ]
  end
end

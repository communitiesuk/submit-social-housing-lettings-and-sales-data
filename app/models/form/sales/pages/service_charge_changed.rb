class Form::Sales::Pages::ServiceChargeChanged < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "service_charge_changed"
    @copy_key = "sales.sale_information.servicecharges_changed"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HasServiceChargesChanged.new(nil, nil, self),
      Form::Sales::Questions::NewServiceCharges.new(nil, nil, self),
    ]
  end
end

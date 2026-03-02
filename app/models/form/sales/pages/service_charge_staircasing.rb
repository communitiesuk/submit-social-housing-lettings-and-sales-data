class Form::Sales::Pages::ServiceChargeStaircasing < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @copy_key = "sales.sale_information.servicecharges"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HasServiceCharge.new(nil, nil, self, staircasing: true),
      Form::Sales::Questions::ServiceCharge.new(nil, nil, self, staircasing: true),
    ]
  end
end

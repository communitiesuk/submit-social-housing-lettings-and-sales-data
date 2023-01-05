class Form::Sales::Pages::AboutDepositWithoutDiscount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = "About the deposit"
    @description = ""
    @subsection = subsection
    @depends_on = [{ "is_type_discount?" => false }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositAmount.new(nil, nil, self),
    ]
  end
end

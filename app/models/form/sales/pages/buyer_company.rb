class Form::Sales::Pages::BuyerCompany < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_company"
    @copy_key = "sales.setup.companybuy"
    @depends_on = [{
      "outright_sale?" => true,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerCompany.new(nil, nil, self),
    ]
  end
end

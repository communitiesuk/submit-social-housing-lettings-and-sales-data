class Form::Sales::Pages::BuyerCompany < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_company"
    @subsection = subsection
    @depends_on = [{
      "ownershipsch" => 3,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerCompany.new(nil, nil, self),
    ]
  end
end

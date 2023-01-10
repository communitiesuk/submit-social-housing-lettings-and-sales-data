class Form::Sales::Pages::Buyer1Mortgage < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_mortgage"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1Mortgage.new(nil, nil, self),
    ]
  end
end

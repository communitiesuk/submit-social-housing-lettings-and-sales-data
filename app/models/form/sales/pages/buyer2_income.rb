class Form::Sales::Pages::Buyer2Income < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_income"
    @depends_on = [{
      "joint_purchase?" => true,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2IncomeKnown.new(nil, nil, self),
      Form::Sales::Questions::Buyer2Income.new(nil, nil, self),
    ]
  end
end

class Form::Sales::Pages::Buyer2Mortgage < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_mortgage"
    @depends_on = [{ "joint_purchase?" => true }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2Mortgage.new(nil, nil, self),
    ]
  end
end

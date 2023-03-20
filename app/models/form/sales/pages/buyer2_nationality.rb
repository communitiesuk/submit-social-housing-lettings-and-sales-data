class Form::Sales::Pages::Buyer2Nationality < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_nationality"
    @depends_on = [{ "joint_purchase?" => true }]
  end

  def questions
    @questions ||= [Form::Sales::Questions::Buyer2Nationality.new(nil, nil, self)]
  end
end

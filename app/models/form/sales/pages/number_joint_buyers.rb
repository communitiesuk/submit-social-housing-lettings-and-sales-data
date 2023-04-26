class Form::Sales::Pages::NumberJointBuyers < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "number_joint_buyers"
    @depends_on = [{
      "joint_purchase?" => true,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::NumberJointBuyers.new(nil, nil, self),
    ]
  end
end

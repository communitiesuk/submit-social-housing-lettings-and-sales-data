class Form::Sales::Pages::JointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::JointPurchase.new(nil, nil, self),
    ]
  end
end

class Form::Sales::Pages::PreviousOwnership < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
    @depends_on = [{ "joint_purchase?" => @joint_purchase }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Prevown.new(nil, nil, self, joint_purchase: @joint_purchase),
    ]
  end
end

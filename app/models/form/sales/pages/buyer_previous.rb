class Form::Sales::Pages::BuyerPrevious < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
    @copy_key = "sales.sale_information.soctenant.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerPrevious.new(nil, nil, self, joint_purchase: @joint_purchase),
    ]
  end

  def routed_to?(_log, _current_user)
    false
  end
end

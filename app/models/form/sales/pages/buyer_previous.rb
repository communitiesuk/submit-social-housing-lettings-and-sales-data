class Form::Sales::Pages::BuyerPrevious < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
    @copy_key = "sales.sale_information.soctenant.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
    @depends_on = [{ "joint_purchase?" => joint_purchase, "soctenant_is_inferred?" => false }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerPrevious.new(nil, nil, self, joint_purchase: @joint_purchase),
    ]
  end

  def routed_to?(log, _current_user)
    return false if log.is_staircase? && form.start_year_2024_or_later?

    super
  end
end

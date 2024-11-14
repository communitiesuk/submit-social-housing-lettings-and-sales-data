class Form::Sales::Pages::LivingBeforePurchase < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:, joint_purchase:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @joint_purchase = joint_purchase
    @copy_key = "sales.sale_information.living_before_purchase.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
  end

  def questions
    @questions ||= [
      living_before_purchase,
      Form::Sales::Questions::LivingBeforePurchaseYears.new(nil, nil, self, ownershipsch: @ownershipsch, joint_purchase: @joint_purchase),
    ].compact
  end

  def living_before_purchase
    if form.start_date.year >= 2023
      Form::Sales::Questions::LivingBeforePurchase.new(nil, nil, self, ownershipsch: @ownershipsch, joint_purchase: @joint_purchase)
    end
  end

  def routed_to?(log, _user)
    super && page_routed_to?(log)
  end

  def page_routed_to?(log)
    return false if form.start_year_2025_or_later? && log.resale != 2

    if @joint_purchase
      log.joint_purchase?
    else
      log.not_joint_purchase? || log.jointpur.nil?
    end
  end
end

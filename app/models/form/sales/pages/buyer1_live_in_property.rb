class Form::Sales::Pages::Buyer1LiveInProperty < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_live_in_property"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1LiveInProperty.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user)
    super && page_routed_to?(log)
  end

  def page_routed_to?(log)
    return false if log.form.start_year_2025_or_later? && log.is_staircase?

    privacy_notice_seen_or_not_interviewed = log.buyer_has_seen_privacy_notice? || log.buyer_not_interviewed?
    not_outright_sale = !log.outright_sale?
    joint_purchase_and_live_in = log.joint_purchase? && log.buyers_will_live_in?

    return true if privacy_notice_seen_or_not_interviewed && not_outright_sale
    return true if privacy_notice_seen_or_not_interviewed && joint_purchase_and_live_in

    false
  end
end

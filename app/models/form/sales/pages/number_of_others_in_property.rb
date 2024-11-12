class Form::Sales::Pages::NumberOfOthersInProperty < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::NumberOfOthersInProperty.new(nil, nil, self, joint_purchase: @joint_purchase),
    ]
  end

  def routed_to?(log, _current_user)
    super && page_routed_to?(log)
  end

  def page_routed_to?(log)
    return false unless log.joint_purchase? == @joint_purchase
    return false if log.form.start_year_2025_or_later? && log.is_staircase?

    log.buyer_has_seen_privacy_notice? || log.buyer_not_interviewed?
  end
end

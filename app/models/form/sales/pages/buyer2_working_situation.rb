class Form::Sales::Pages::Buyer2WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_working_situation"
    @copy_key = "sales.household_characteristics.ecstat2.buyer"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2WorkingSituation.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user)
    super && page_routed_to?(log)
  end

  def page_routed_to?(log)
    return false unless log.joint_purchase?
    return false if log.form.start_year_2025_or_later? && log.is_staircase?

    log.buyer_has_seen_privacy_notice? || log.buyer_not_interviewed?
  end
end

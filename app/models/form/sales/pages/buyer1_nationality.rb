class Form::Sales::Pages::Buyer1Nationality < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_nationality"
  end

  def questions
    @questions ||= if form.start_year_2024_or_later?
                     [
                       Form::Sales::Questions::NationalityAllGroup.new("nationality_all_group", nil, self, 1),
                       Form::Sales::Questions::NationalityAll.new("nationality_all", nil, self, 1),
                     ]
                   else
                     [Form::Sales::Questions::Buyer1Nationality.new(nil, nil, self)]
                   end
  end

  def routed_to?(log, _current_user)
    super && page_routed_to?(log)
  end

  def page_routed_to?(log)
    return false if log.form.start_year_2025_or_later? && log.is_staircase?

    log.buyer_has_seen_privacy_notice? || log.buyer_not_interviewed?
  end
end

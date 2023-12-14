class Form::Sales::Questions::ManagingOrganisation < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "managing_organisation_id"
    @check_answer_label = "Reported by"
    @header = "Which organisation is reporting this sale?"
    @type = "select"
  end

  def answer_options(log = nil, user = nil)
    opts = { "" => "Select an option" }

    return opts unless ActiveRecord::Base.connected?
    return opts unless user
    return opts unless log

    if log.managing_organisation.present?
      opts = opts.merge({ log.managing_organisation.id => log.managing_organisation.name })
    end

    if user.support?
      if log.owning_organisation.holds_own_stock?
        opts[log.owning_organisation.id] = "#{log.owning_organisation.name} (Owning organisation)"
      end
    elsif user.organisation.absorbed_organisations.exists? && user.organisation.available_from.present?
      opts[user.organisation.id] = "#{user.organisation.name} (Your organisation, active as of #{user.organisation.available_from.to_fs(:govuk_date)})"
    else
      opts[user.organisation.id] = "#{user.organisation.name} (Your organisation)"
    end

    orgs = if user.support?
             log.owning_organisation.managing_agents
           elsif user.organisation.absorbed_organisations.include?(log.owning_organisation)
             user.organisation.managing_agents + log.owning_organisation.managing_agents
           else
             user.organisation.managing_agents
           end.pluck(:id, :name).to_h

    user.organisation.absorbed_organisations.each do |absorbed_org|
      opts[absorbed_org.id] = "#{absorbed_org.name} (inactive as of #{absorbed_org.merge_date.to_fs(:govuk_date)})"
    end

    opts.merge(orgs)
  end

  def displayed_answer_options(log, user)
    answer_options(log, user)
  end

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    answer_options[value]
  end

  def derived?
    true
  end

  def hidden_in_check_answers?(log, user = nil)
    user.nil? || !user.support? || !@page.routed_to?(log, user)
  end

  def enabled
    true
  end

  def answer_label(log, _current_user = nil)
    Organisation.find_by(id: log.managing_organisation_id)&.name
  end

private

  def selected_answer_option_is_derived?(_log)
    true
  end
end
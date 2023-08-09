class Form::Sales::Questions::OwningOrganisationId < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "owning_organisation_id"
    @check_answer_label = "Owning organisation"
    @header = "Which organisation owns this log?"
    @type = "select"
  end

  def answer_options(log = nil, user = nil)
    answer_opts = { "" => "Select an option" }

    return answer_opts unless ActiveRecord::Base.connected?

    if FeatureToggle.merge_organisations_enabled?
      return answer_opts unless user
      return answer_opts unless log

      if log.owning_organisation_id.present?
        answer_opts = answer_opts.merge({ log.owning_organisation.id => log.owning_organisation.name })
      end

      if !user.support? && user.organisation.holds_own_stock?
        answer_opts[user.organisation.id] = "#{user.organisation.name} (Your organisation)"
      end

      user_answer_options = if user.support?
                              Organisation.where(holds_own_stock: true)
                            else
                              user.organisation.stock_owners + user.organisation.absorbed_organisations.where(holds_own_stock: true)
                            end.pluck(:id, :name).to_h

      answer_opts.merge(user_answer_options)
    else
      Organisation.select(:id, :name).each_with_object(answer_opts) do |organisation, hsh|
        hsh[organisation.id] = organisation.name
        hsh
      end
    end
  end

  def displayed_answer_options(log, user = nil)
    answer_options(log, user)
  end

  def label_from_value(value, log = nil, user = nil)
    return unless value

    answer_options(log, user)[value]
  end

  def derived?
    true
  end

  def hidden_in_check_answers?(_log, user = nil)
    if FeatureToggle.merge_organisations_enabled?
      return false if user.support?

      stock_owners = user.organisation.stock_owners + user.organisation.absorbed_organisations.where(holds_own_stock: true)

      if user.organisation.holds_own_stock?
        stock_owners.count.zero?
      else
        stock_owners.count <= 1
      end
    else
      !current_user.support?
    end
  end

  def enabled
    true
  end

private

  def selected_answer_option_is_derived?(_log)
    if FeatureToggle.merge_organisations_enabled?
      true
    else
      false
    end
  end
end

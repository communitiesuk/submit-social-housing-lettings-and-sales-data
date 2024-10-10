class Form::Sales::Questions::OwningOrganisationId < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "owning_organisation_id"
    @derived = true
    @type = "select"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def answer_options(log = nil, user = nil)
    answer_opts = { "" => "Select an option" }

    return answer_opts unless ActiveRecord::Base.connected?
    return answer_opts unless user
    return answer_opts unless log

    if log.owning_organisation_id.present?
      org_value = log.owning_organisation.label
      answer_opts[log.owning_organisation.id] = org_value
    end

    unless user.support?
      if user.organisation.holds_own_stock?
        answer_opts[user.organisation.id] = "#{user.organisation.name} (Your organisation)"
      end

      user.organisation.stock_owners.visible.filter_by_active.where(holds_own_stock: true).find_each do |org|
        answer_opts[org.id] = org.name
      end
    end

    recently_absorbed_organisations = user.organisation.absorbed_organisations.visible.merged_during_open_collection_period
    if !user.support? && user.organisation.holds_own_stock?
      answer_opts[user.organisation.id] = if recently_absorbed_organisations.exists? && user.organisation.available_from.present?
                                            "#{user.organisation.name} (Your organisation, active as of #{user.organisation.available_from.to_fs(:govuk_date)})"
                                          else
                                            "#{user.organisation.name} (Your organisation)"
                                          end
    end

    if user.support?
      Organisation.visible.filter_by_active.where(holds_own_stock: true).find_each do |org|
        if org.merge_date.present?
          answer_opts[org.id] = "#{org.name} (inactive as of #{org.merge_date.to_fs(:govuk_date)})" if org.merge_date >= FormHandler.instance.start_date_of_earliest_open_for_editing_collection_period
        elsif org.absorbed_organisations.merged_during_open_collection_period.exists? && org.available_from.present?
          answer_opts[org.id] = "#{org.name} (active as of #{org.available_from.to_fs(:govuk_date)})"
        else
          answer_opts[org.id] = org.name
        end
      end
    else
      recently_absorbed_organisations.visible.each do |absorbed_org|
        answer_opts[absorbed_org.id] = merged_organisation_label(absorbed_org.name, absorbed_org.merge_date) if absorbed_org.holds_own_stock?
      end
    end

    answer_opts
  end

  def displayed_answer_options(log, user = nil)
    answer_options(log, user)
  end

  def label_from_value(value, log = nil, user = nil)
    return unless value

    answer_options(log, user)[value]
  end

  def hidden_in_check_answers?(_log, user = nil)
    return false if user.support?

    stock_owners = user.organisation.stock_owners.visible + user.organisation.absorbed_organisations.visible.where(holds_own_stock: true)

    if user.organisation.holds_own_stock?
      stock_owners.count.zero?
    else
      stock_owners.count <= 1
    end
  end

  def enabled
    true
  end

private

  def selected_answer_option_is_derived?(_log)
    true
  end

  def merged_organisation_label(name, merge_date)
    "#{name} (inactive as of #{merge_date.to_fs(:govuk_date)})"
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => nil, 2024 => 1 }.freeze
end

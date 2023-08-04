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
    return answer_opts unless user
    return answer_opts unless log

    if log.owning_organisation_id.present?
      answer_opts[log.owning_organisation.id] = log.owning_organisation.name
    end

    recently_absorbed_organisations = user.organisation.absorbed_organisations.merged_during_open_collection_period
    if !user.support? && user.organisation.holds_own_stock?
      answer_opts[user.organisation.id] = if recently_absorbed_organisations.exists?
                                            "#{user.organisation.name} (Your organisation, active as of #{user.organisation.created_at.to_fs(:govuk_date)})"
                                          else
                                            "#{user.organisation.name} (Your organisation)"
                                          end
    end

    user_organisation_options = user.support? ? Organisation.where(holds_own_stock: true) : user.organisation.stock_owners
    user_answer_options = user_organisation_options.pluck(:id, :name).to_h

    unless user.support?
      recently_absorbed_organisations.each do |absorbed_org|
        answer_opts[absorbed_org.id] = merged_organisation_label(absorbed_org.name, absorbed_org.merge_date) if absorbed_org.holds_own_stock?
        absorbed_org.stock_owners.each do |stock_owner|
          user_answer_options[stock_owner.id] = merged_organisation_label(stock_owner.name, absorbed_org.merge_date)
        end
      end
    end

    answer_opts.merge(user_answer_options)
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
    return false if user.support?

    stock_owners = user.organisation.stock_owners + user.organisation.absorbed_organisations.where(holds_own_stock: true)

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
end

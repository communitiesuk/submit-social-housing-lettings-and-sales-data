class Form::Lettings::Questions::StockOwner < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "owning_organisation_id"
    @check_answer_label = "Stock owner"
    @header = "Which organisation owns this property?"
    @type = "select"
    @question_number = 1
  end

  def answer_options(log = nil, user = nil)
    answer_opts = { "" => "Select an option" }

    return answer_opts unless ActiveRecord::Base.connected?
    return answer_opts unless user
    return answer_opts unless log

    if log.owning_organisation_id.present?
      answer_opts = answer_opts.merge({ log.owning_organisation.id => log.owning_organisation.name })
    end

    if !user.support? && user.organisation.holds_own_stock?
      answer_opts[user.organisation.id] = "#{user.organisation.name} (Your organisation, active as of #{user.organisation.created_at.to_time.to_formatted_s(:govuk_date)})"
    end

    user_answer_options = if user.support?
                            Organisation.where(holds_own_stock: true).pluck(:id, :name).to_h
                          else
                            stock_owners = user.organisation.stock_owners
                                               .map { |stock_owner| [stock_owner.id, stock_owner.name] }.to_h
                            absorbed_stock_owning_orgs = user.organisation.absorbed_organisations
                                                        .where(holds_own_stock: true)
                                                        .map { |org| [org.id, "#{org.name} (Inactive as of #{org.merge_date.to_time.to_formatted_s(:govuk_date)})"] }.to_h

                            stock_owners.merge(absorbed_stock_owning_orgs)
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
end

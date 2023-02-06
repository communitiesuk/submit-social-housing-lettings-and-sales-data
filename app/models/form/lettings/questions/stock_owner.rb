class Form::Lettings::Questions::StockOwner < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "owning_organisation_id"
    @check_answer_label = "Stock owner"
    @header = "Which organisation owns this property?"
    @type = "select"
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
      answer_opts[user.organisation.id] = "#{user.organisation.name} (Your organisation)"
    end

    stock_owners_answer_options = if user.support?
                                    Organisation
                                  else
                                    user.organisation.stock_owners
                                  end.pluck(:id, :name).to_h

    answer_opts.merge(stock_owners_answer_options)
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

    stock_owners = user.organisation.stock_owners

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

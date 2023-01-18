class Form::Lettings::Questions::StockOwner < ::Form::Question
  attr_accessor :current_user, :log

  def initialize(id, hsh, page)
    super
    @id = "owning_organisation_id"
    @check_answer_label = "Stock owner"
    @header = "Which organisation owns this property?"
    @type = "select"
  end

  def answer_options
    answer_opts = { "" => "Select an option" }
    return answer_opts unless ActiveRecord::Base.connected?
    return answer_opts unless current_user

    if !current_user.support? && current_user.organisation.holds_own_stock?
      answer_opts[current_user.organisation.id] = "#{current_user.organisation.name} (Your organisation)"
    end

    answer_opts.merge(stock_owners_answer_options)
  end

  def displayed_answer_options(log, user = nil)
    @current_user = user
    @log = log

    answer_options
  end

  def label_from_value(value)
    return unless value

    answer_options[value]
  end

  def derived?
    true
  end

  def hidden_in_check_answers?(_log, user = nil)
    @current_user = user

    return false if current_user.support?

    stock_owners = current_user.organisation.stock_owners

    if current_user.organisation.holds_own_stock?
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

  def stock_owners_answer_options
    if current_user.support?
      Organisation
    else
      current_user.organisation.stock_owners
    end.pluck(:id, :name).to_h
  end
end

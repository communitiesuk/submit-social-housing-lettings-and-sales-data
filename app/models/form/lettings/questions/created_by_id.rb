class Form::Lettings::Questions::CreatedById < ::Form::Question
  ANSWER_OPTS = { "" => "Select an option" }.freeze

  def initialize(id, hsh, page)
    super
    @id = "created_by_id"
    @check_answer_label = "Log owner"
    @header = "Which user are you creating this log for?"
    @type = "select"
  end

  def answer_options
    return ANSWER_OPTS unless ActiveRecord::Base.connected?

    User.select(:id, :name, :email).each_with_object(ANSWER_OPTS.dup) do |user, hsh|
      hsh[user.id] = "#{user.name} (#{user.email})"
      hsh
    end
  end

  def displayed_answer_options(log, user = nil)
    return ANSWER_OPTS unless user
    return ANSWER_OPTS unless user.support? || user.data_coordinator?

    user_ids = [""]
    user_ids += if user.support?
                  [
                    (log.owning_organisation&.users&.pluck(:id) if log.owning_organisation),
                    (log.managing_organisation&.users&.pluck(:id) if log.managing_organisation),
                  ]
                else
                  user.organisation.users.pluck(:id)
                end.flatten.uniq

    answer_options.select { |k, _v| user_ids.include?(k) }
  end

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    answer_options[value]
  end

  def hidden_in_check_answers?(_log, current_user)
    return false if current_user.support?
    return false if current_user.data_coordinator?

    true
  end

  def derived?
    true
  end

private

  def selected_answer_option_is_derived?(_log)
    true
  end
end

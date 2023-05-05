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
    ANSWER_OPTS
  end

  def displayed_answer_options(log, current_user = nil)
    return ANSWER_OPTS unless current_user

    users = []
    users += if current_user.support?
               [
                 (log.owning_organisation&.users if log.owning_organisation),
                 (log.managing_organisation&.users if log.managing_organisation),
               ].flatten
             else
               current_user.organisation.users
             end.uniq.compact

    users.each_with_object(ANSWER_OPTS.dup) do |user, hsh|
      hsh[user.id] = present_user(user)
      hsh
    end
  end

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    present_user(User.find(value))
  end

  def derived?
    true
  end

private

  def present_user(user)
    "#{user.name} (#{user.email})"
  end

  def selected_answer_option_is_derived?(_log)
    true
  end
end

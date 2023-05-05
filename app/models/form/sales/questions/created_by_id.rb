class Form::Sales::Questions::CreatedById < ::Form::Question
  ANSWER_OPTS = { "" => "Select an option" }.freeze

  def initialize(id, hsh, page)
    super
    @id = "created_by_id"
    @check_answer_label = "User"
    @header = "Which user are you creating this log for?"
    @type = "select"
  end

  def answer_options
    ANSWER_OPTS
  end

  def displayed_answer_options(log, current_user = nil)
    return ANSWER_OPTS unless log.owning_organisation
    return ANSWER_OPTS unless current_user

    users = current_user.support? ? log.owning_organisation.users : current_user.organisation.users

    users.each_with_object(ANSWER_OPTS.dup) do |user, hsh|
      hsh[user.id] = present_user(user)
      hsh
    end
  end

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    present_user(User.find(value))
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

  def present_user(user)
    "#{user.name} (#{user.email})"
  end

  def selected_answer_option_is_derived?(_log)
    false
  end
end

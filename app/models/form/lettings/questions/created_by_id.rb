class Form::Lettings::Questions::CreatedById < ::Form::Question
  ANSWER_OPTS = { "" => "Select an option" }.freeze

  def initialize(id, hsh, page)
    super
    @id = "assigned_to_id"
    @derived = true
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
                 (
                   if log.owning_organisation
                     log.owning_organisation.absorbing_organisation.present? ? log.owning_organisation&.absorbing_organisation&.users&.visible : log.owning_organisation&.users&.visible
                   end),
                 (
                   if log.managing_organisation
                     log.managing_organisation.absorbing_organisation.present? ? log.managing_organisation&.absorbing_organisation&.users&.visible : log.managing_organisation.users&.visible
                   end),
               ].flatten
             else
               current_user.organisation.users.visible
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

private

  def present_user(user)
    "#{user.name} (#{user.email})"
  end

  def selected_answer_option_is_derived?(_log)
    true
  end
end

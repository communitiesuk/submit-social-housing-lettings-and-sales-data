class Form::Sales::Questions::CreatedById < ::Form::Question
  ANSWER_OPTS = { "" => "Select an option" }.freeze

  def initialize(id, hsh, page)
    super
    @id = "assigned_to_id"
    @check_answer_label = I18n.t("forms.#{form.start_date.year}.sales.setup.assigned_to_id.check_answer_label")
    @header = I18n.t("forms.#{form.start_date.year}.sales.setup.assigned_to_id.question_text")
    @hint = I18n.t("forms.#{form.start_date.year}.sales.setup.assigned_to_id.hint_text")
    @derived = true
    @type = "select"
  end

  def answer_options
    ANSWER_OPTS
  end

  def displayed_answer_options(log, current_user = nil)
    return ANSWER_OPTS unless log.managing_organisation
    return ANSWER_OPTS unless current_user

    users = []
    users += if current_user.support?
               [
                 (
                   if log.managing_organisation
                     log.managing_organisation.absorbing_organisation.present? ? log.managing_organisation&.absorbing_organisation&.users&.visible : log.managing_organisation.users.visible
                   end),
               ].flatten
             else
               log.managing_organisation.users.visible
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

  def hidden_in_check_answers?(_log, current_user)
    return false if current_user.support?
    return false if current_user.data_coordinator?

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

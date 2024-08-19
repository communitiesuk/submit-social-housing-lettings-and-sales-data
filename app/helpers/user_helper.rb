module UserHelper
  def aliased_user_edit(user, current_user)
    current_user == user ? edit_account_path : edit_user_path(user)
  end

  def perspective(user, current_user)
    current_user == user ? "Are you" : "Is this person"
  end

  def can_edit_org?(current_user)
    current_user.data_coordinator? || current_user.support?
  end

  def delete_user_link(user)
    govuk_button_link_to "Delete this user", delete_confirmation_user_path(user), warning: true
  end

  def organisation_change_warning(user, new_organisation)
    logs_count = user.assigned_to_lettings_logs.count + user.assigned_to_sales_logs.count
    logs_count_text = logs_count == 1 ? "is #{logs_count} log" : "are #{logs_count} logs"

    "You’re moving #{user.name} from #{user.organisation.name} to #{new_organisation.name}. There #{logs_count_text} assigned to them."
  end
end

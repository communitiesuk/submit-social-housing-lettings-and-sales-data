module UserHelper
  def aliased_user_edit(user, current_user)
    current_user == user ? edit_account_path : edit_user_path(user)
  end

  def pronoun(user, current_user)
    current_user == user ? "you" : "they"
  end

  def can_edit_names?(user, current_user)
    current_user == user || current_user.data_coordinator? || current_user.support?
  end

  def can_edit_emails?(user, current_user)
    current_user == user || current_user.data_coordinator? || current_user.support?
  end

  def can_edit_password?(user, current_user)
    current_user == user
  end

  def can_edit_roles?(_user, current_user)
    current_user.data_coordinator? || current_user.support?
  end

  def can_edit_dpo?(_user, current_user)
    current_user.data_coordinator? || current_user.support?
  end

  def can_edit_key_contact?(_user, current_user)
    current_user.data_coordinator? || current_user.support?
  end
end

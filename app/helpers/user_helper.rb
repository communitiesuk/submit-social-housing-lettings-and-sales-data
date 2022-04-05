module UserHelper
  def aliased_user_edit(user, current_user)
    current_user == user ? edit_account_path : edit_user_path(user)
  end

  def pronoun(user, current_user)
    current_user == user ? "you" : "they"
  end
end

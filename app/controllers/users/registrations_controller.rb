class Users::RegistrationsController < Devise::RegistrationsController
protected

  def after_update_path_for(_resource)
    users_account_path
  end
end

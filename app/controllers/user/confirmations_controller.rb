class User::ConfirmationsController < Devise::ConfirmationsController
protected

  def after_confirmation_path_for(_resource_name, resource)
    new_user_confirmation_path(resource)
  end
end

class Users::RegistrationsController < Devise::RegistrationsController
  skip_before_action :require_no_authentication

  def new
    self.resource = resource_class.new
    respond_with resource
  end

protected

  def after_update_path_for(_resource)
    users_account_path
  end
end

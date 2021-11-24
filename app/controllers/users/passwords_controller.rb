class Users::PasswordsController < Devise::PasswordsController
  def reset_confirmation
    @email = params["email"]
    flash[:notice] = "Reset password instructions have been sent to #{@email}"
    render "devise/confirmations/reset"
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
  end

protected

  def after_sending_reset_password_instructions_path_for(_resource)
    confirmations_reset_path(email: params.dig("user", "email"))
  end
end

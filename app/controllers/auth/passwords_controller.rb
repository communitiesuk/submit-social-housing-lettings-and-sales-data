class Auth::PasswordsController < Devise::PasswordsController
  include Helpers::Email

  def reset_confirmation
    self.resource = resource_class.new
    @email = params["email"]
    if @email.empty?
      resource.errors.add :email, "Enter an email address"
      render "devise/passwords/new", status: :unprocessable_entity
    elsif !email_valid?(@email)
      resource.errors.add :email, "Enter an email address in the correct format, like name@example.com"
      render "devise/passwords/new", status: :unprocessable_entity
    else
      render "devise/confirmations/reset"
    end
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
  end

  def edit
    super
    render "devise/passwords/reset_password"
  end

protected

  def resource_class_name
    resource_class.name.underscore
  end

  def after_sending_reset_password_instructions_path_for(_resource)
    confirmations_reset_path(email: params.dig(resource_class_name, "email"))
  end

  def after_resetting_password_path_for(resource)
    if Devise.sign_in_after_reset_password
      if resource_class == AdminUser
        resource.send_new_otp
        admin_user_two_factor_authentication_path
      else
        after_sign_in_path_for(resource)
      end
    else
      new_session_path(resource_name)
    end
  end
end

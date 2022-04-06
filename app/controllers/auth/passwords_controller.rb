class Auth::PasswordsController < Devise::PasswordsController
  include Helpers::Email

  def reset_confirmation
    self.resource = resource_class.new
    @email = params["email"]
    if @email.empty?
      resource.errors.add :email, I18n.t("validations.email.blank")
      render "devise/passwords/new", status: :unprocessable_entity
    elsif !email_valid?(@email)
      resource.errors.add :email, I18n.t("validations.email.invalid")
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

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        set_flash_message!(:notice, password_update_flash_message)
        resource.after_database_authentication
        sign_in(resource_name, resource)
        set_2fa_required
      else
        set_flash_message!(:notice, :updated_not_active)
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      set_minimum_password_length
      respond_with resource, status: :unprocessable_entity
    end
  end

protected

  def set_2fa_required
    return unless resource.respond_to?(:need_two_factor_authentication?) &&
      resource.need_two_factor_authentication?(request)

    warden.session(resource_class.name.underscore)[TwoFactorAuthentication::NEED_AUTHENTICATION] = true
  end

  def password_update_flash_message
    resource.need_two_factor_authentication?(request) ? :updated_2FA : :updated
  end

  def resource_class_name
    resource_class.name.underscore
  end

  def after_sending_reset_password_instructions_path_for(_resource)
    account_password_reset_confirmation_path(email: params.dig(resource_class_name, "email"))
  end

  def after_resetting_password_path_for(resource)
    if Devise.sign_in_after_reset_password
      if resource.need_two_factor_authentication?(request)
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

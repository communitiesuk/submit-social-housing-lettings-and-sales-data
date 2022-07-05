class Auth::TwoFactorAuthenticationController < Devise::TwoFactorAuthenticationController
  def show_resend
    render "devise/two_factor_authentication/resend"
  end

  def update
    resource.errors.add :base, I18n.t("devise.two_factor_authentication.code_required") if resource && params_code.empty?
    super
  end

private

  def after_two_factor_fail_for(resource)
    resource.second_factor_attempts_count += 1
    resource.save!

    if resource.max_login_attempts?
      sign_out(resource)
      render :max_login_attempts_reached, status: :unprocessable_entity
    else
      resource.errors.add :base, I18n.t("devise.two_factor_authentication.code_incorrect") if resource
      render :show, status: :unprocessable_entity
    end
  end

  def after_two_factor_success_for(resource)
    set_remember_two_factor_cookie(resource)
    warden.session(resource_name)[DeviseTwoFactorAuthentication::NEED_AUTHENTICATION] = false
    bypass_sign_in(resource, scope: resource_name)
    resource.update!(second_factor_attempts_count: 0)

    redirect_to after_two_factor_success_path_for(resource)
  end

  def after_two_factor_success_path_for(resource)
    if resource.is_a?(User) && resource.support?
      "/organisations"
    else
      super
    end
  end
end

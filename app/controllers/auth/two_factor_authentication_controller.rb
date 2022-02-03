class Auth::TwoFactorAuthenticationController < Devise::TwoFactorAuthenticationController
  def show_resend
    render "devise/two_factor_authentication/resend"
  end
end

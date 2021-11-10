class Users::PasswordsController < Devise::PasswordsController

  def reset_confirmation
    @email = params["email"]
    render "devise/confirmations/reset"
  end 

  protected

    def after_sending_reset_password_instructions_path_for(resource)
      confirmations_reset_path(email: params.dig("user", "email")) if is_navigational_format?
    end
end
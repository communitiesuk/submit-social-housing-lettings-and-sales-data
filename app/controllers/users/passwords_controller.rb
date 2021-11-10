class Users::PasswordsController < Devise::PasswordsController

  def reset_confirmation
    @user = User.find(params["id"])
    render "devise/confirmations/reset"
  end 

  protected

    def after_sending_reset_password_instructions_path_for(resource)
      confirmations_reset_path(id: @user.id) if is_navigational_format?
    end
end
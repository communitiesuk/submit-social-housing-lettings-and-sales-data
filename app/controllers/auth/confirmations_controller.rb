class Auth::ConfirmationsController < Devise::ConfirmationsController

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message!(:notice, :confirmed)
      token = resource.send(:set_reset_password_token)
      base = public_send("edit_#{resource_class.name.underscore}_password_url")
      url = "#{base}?reset_password_token=#{token}"
      redirect_to url
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end

protected

  def after_confirmation_path_for(resource_name, resource)
    edit_user_password_path(email: resource.email)
  end
end

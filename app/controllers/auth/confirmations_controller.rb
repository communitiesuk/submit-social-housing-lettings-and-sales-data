class Auth::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      if resource.sign_in_count.zero?
        token = resource.send(:set_reset_password_token)
        redirect_to controller: "auth/passwords", action: "edit", reset_password_token: token, confirmation: true
      else
        respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
      end
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end
end

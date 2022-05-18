class Auth::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      if resource.sign_in_count.zero?
        token = resource.send(:set_reset_password_token)
        redirect_to "#{edit_user_password_url}?reset_password_token=#{token}&confirmation=true"
      else
        respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
      end
    elsif resource.errors.map(&:type).include?(:confirmation_period_expired)
      render "devise/confirmations/expired"
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end
end

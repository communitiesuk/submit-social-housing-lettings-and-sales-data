class Auth::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      # previously we reset sign in count to indicate that a user was deactivated and so needs to reset their password on confirming their email post reactivation.
      # now we have a specific flag for this.
      # though for backwards compatability we need to ensure previous users with a reset sign in count still will see the password reset screen
      if resource.reset_password_on_confirmation || resource.sign_in_count.zero?
        token = resource.send(:set_reset_password_token)
        redirect_to "#{edit_user_password_url}?reset_password_token=#{token}&confirmation=true"
      else
        respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
      end
    elsif %i[blank invalid].any? { |error| resource.errors.map(&:type).include?(error) }
      render "devise/confirmations/invalid"
    elsif resource.errors.map(&:type).include?(:already_confirmed)
      flash[:notice] = I18n.t("errors.messages.already_confirmed")
      redirect_to user_session_path
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end
end

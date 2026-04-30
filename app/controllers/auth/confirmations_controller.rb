class Auth::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      # previously we reset sign_in_count on deactivation and had only the .zero? check here.
      # this would force a password reset both if it was your very first log in, and on your first login after reactivation.
      # now we have a specific flag for the latter case as resetting sign_in_count was difficult for auditing.
      # note that some deactivated users will have a sign_in_count of 0 and not have this flag set if they were deactivated before we made this change.
      if resource.force_reset_password_on_confirmation || resource.sign_in_count.zero?
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

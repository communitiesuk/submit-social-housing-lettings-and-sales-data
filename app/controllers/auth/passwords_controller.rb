class Auth::PasswordsController < Devise::PasswordsController
  include Helpers::Email

  def reset_confirmation
    self.resource = resource_class.new
    @email = params["email"]
    if @email.empty?
      resource.errors.add :email, "Enter an email address"
      render "devise/passwords/new", status: :unprocessable_entity
    elsif !email_valid?(@email)
      resource.errors.add :email, "Enter an email address in the correct format, like name@example.com"
      render "devise/passwords/new", status: :unprocessable_entity
    else
      flash[:notice] = "Reset password instructions have been sent to #{@email}"
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
    render "users/reset_password"
  end

protected

  def after_sending_reset_password_instructions_path_for(_resource)
    confirmations_reset_path(email: params.dig("user", "email"))
  end
end

class Auth::SessionsController < Devise::SessionsController
  include Helpers::Email

  def create
    self.resource = resource_class.new
    if params.dig(resource_class_name, "email").empty?
      resource.errors.add :email, "Enter an email address"
    elsif !email_valid?(params.dig(resource_class_name, "email"))
      resource.errors.add :email, "Enter an email address in the correct format, like name@example.com"
    end
    if params.dig(resource_class_name, "password").empty?
      resource.errors.add :password, "Enter a password"
    end
    if resource.errors.present?
      render :new, status: :unprocessable_entity
    else
      super
    end
  end

private

  def resource_class
    request.path.include?("admin") ? AdminUser : User
  end

  def resource_class_name
    resource_class.name.underscore
  end

  def after_sign_in_path_for(resource)
    if resource_class == AdminUser
      admin_user_two_factor_authentication_path
    else
      params.dig(resource_class_name, "start").present? ? case_logs_path : super
    end
  end
end

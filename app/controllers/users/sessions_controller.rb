class Users::SessionsController < Devise::SessionsController
  include Helpers::Email

  def create
    self.resource = resource_class.new
    if params.dig("user", "email").empty?
      resource.errors.add :email, "Enter an email address"
    elsif !email_valid?(params.dig("user", "email"))
      resource.errors.add :email, "Enter an email address in the correct format, like name@example.com"
    end
    if params.dig("user", "password").empty?
      resource.errors.add :password, "Enter a password"
    end
    if resource.errors.present?
      render :new, status: :unprocessable_entity
    else
      super
    end
  end
end

class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = resource_class.new
    if params.dig("user", "email").empty?
      resource.errors.add :email, "Please enter email address"
    elsif !email_valid?(params.dig("user", "email"))
      resource.errors.add :email, "Email addess is not valid"
    end
    if params.dig("user", "password").empty?
      resource.errors.add :password, "Please enter password"
    end
    if resource.errors.present?
      render :new, status: :unprocessable_entity
    else
      super
    end
  end

private

  def email_valid?(email)
    email =~ URI::MailTo::EMAIL_REGEXP
  end
end

class Users::SessionsController < Devise::SessionsController
  def create
    self.resource = resource_class.new
    if params.dig("user", "email").empty?
      resource.errors.add :email, "Please enter email address"
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
end

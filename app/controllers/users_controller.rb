class UsersController < ApplicationController
  include Devise::Controllers::SignInOut
  include Helpers::Email
  before_action :authenticate_user!
  before_action :find_resource, except: %i[new create]
  before_action :authenticate_scope!, except: %i[new create]

  def update
    if @user.update(user_params)
      bypass_sign_in @user
      flash[:notice] = I18n.t("devise.passwords.updated") if user_params.key?("password")
      redirect_to user_path(@user)
    elsif user_params.key?("password")
      format_error_messages
      render "devise/passwords/edit", status: :unprocessable_entity
    else
      format_error_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @resource = User.new
  end

  def create
    @resource = User.new
    if user_params["email"].empty?
      @resource.errors.add :email, "Enter an email address"
    elsif !email_valid?(user_params["email"])
      @resource.errors.add :email, "Enter an email address in the correct format, like name@example.com"
    end
    if @resource.errors.present?
      render :new, status: :unprocessable_entity
    else
      @user = User.create!(user_params.merge(org_params).merge(password_params))
      @user.send_reset_password_instructions
      redirect_to users_organisation_path(current_user.organisation)
    end
  end

  def edit_password
    render "devise/passwords/edit"
  end

private

  def format_error_messages
    errors = @user.errors.to_hash
    @user.errors.clear
    errors.each do |attribute, message|
      @user.errors.add attribute.to_sym, format_error_message(attribute, message)
    end
  end

  def format_error_message(attribute, message)
    [attribute.to_s.humanize.capitalize, message].join(" ")
  end

  def password_params
    { password: SecureRandom.hex(8) }
  end

  def org_params
    { organisation: current_user.organisation }
  end

  def user_params
    params.require(:user).permit(:email, :name, :password, :password_confirmation, :role)
  end

  def find_resource
    @user = User.find(params[:id])
  end

  def authenticate_scope!
    render_not_found if current_user != @user
  end
end

class UsersController < ApplicationController
  include Pagy::Backend
  include Devise::Controllers::SignInOut
  include Helpers::Email
  include Modules::SearchFilter
  before_action :authenticate_user!
  before_action :find_resource, except: %i[new create]
  before_action :authenticate_scope!, except: %i[new]

  def index
    redirect_to users_organisation_path(current_user.organisation) unless current_user.support?

    all_users = User.sorted_by_organisation_and_role
    filtered_users = filtered_users(all_users, search_term)
    @pagy, @users = pagy(filtered_users)
    @searched = search_term.presence
    @total_count = all_users.size

    respond_to do |format|
      format.html
      format.csv do
        if current_user.support?
          send_data filtered_users.to_csv, filename: "users-#{Time.zone.now}.csv"
        else
          head :unauthorized
        end
      end
    end
  end

  def show; end

  def edit
    redirect_to user_path(@user) unless @user.active?
  end

  def update
    if @user.update(user_params)
      if @user == current_user
        bypass_sign_in @user
        flash[:notice] = I18n.t("devise.passwords.updated") if user_params.key?("password")
        redirect_to account_path
      else
        user_name = @user.name&.possessive || @user.email.possessive
        case user_params[:active]
        when "false"
          @user.update!(confirmed_at: nil, sign_in_count: 0)
          flash[:notice] = I18n.t("devise.activation.deactivated", user_name:)
        when "true"
          @user.send_confirmation_instructions
          flash[:notice] = I18n.t("devise.activation.reactivated", user_name:)
        end
        redirect_to user_path(@user)
      end
    elsif user_params.key?("password")
      format_error_messages
      @minimum_password_length = User.password_length.min
      render "devise/passwords/edit", locals: { resource: @user, resource_name: "user" }, status: :unprocessable_entity
    else
      format_error_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    debugger
    @organisation_id = params["organisation_id"]
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(org_params).merge(password_params))
    if @user.save
      redirect_to created_user_redirect_path
    else
      unless @user.errors[:organisation].empty?
        @user.errors.add(:organisation_id, message: @user.errors[:organisation])
        @user.errors.delete(:organisation)
      end
      render :new, status: :unprocessable_entity
    end
  end

  def edit_password
    @minimum_password_length = User.password_length.min
    render "devise/passwords/edit", locals: { resource: @user, resource_name: "user" }
  end

  def deactivate
    if current_user.can_toggle_active?(@user)
      render "toggle_active", locals: { action: "deactivate" }
    else
      redirect_to user_path(@user)
    end
  end

  def reactivate
    if current_user.can_toggle_active?(@user)
      render "toggle_active", locals: { action: "reactivate" }
    else
      redirect_to user_path(@user)
    end
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

  def search_term
    params["search"]
  end

  def password_params
    { password: SecureRandom.hex(8) }
  end

  def org_params
    return {} if current_user.support?

    { organisation: current_user.organisation }
  end

  def user_params
    if @user == current_user
      if current_user.data_coordinator? || current_user.support?
        params.require(:user).permit(:email, :name, :password, :password_confirmation, :role, :is_dpo, :is_key_contact)
      else
        params.require(:user).permit(:email, :name, :password, :password_confirmation)
      end
    elsif current_user.data_coordinator?
      params.require(:user).permit(:email, :name, :role, :is_dpo, :is_key_contact, :active)
    elsif current_user.support?
      params.require(:user).permit(:email, :name, :role, :is_dpo, :is_key_contact, :organisation_id, :active)
    end
  end

  def created_user_redirect_path
    if current_user.support?
      users_path
    else
      users_organisation_path(current_user.organisation)
    end
  end

  def find_resource
    @user = params[:id] ? User.find_by(id: params[:id]) : current_user
  end

  def authenticate_scope!
    if action_name == "create"
      head :unauthorized and return unless current_user.data_coordinator? || current_user.support?
    else
      render_not_found and return unless (current_user.organisation == @user.organisation) || current_user.support?
      render_not_found and return if action_name == "edit_password" && current_user != @user
      render_not_found and return unless action_name == "show" ||
        current_user.data_coordinator? || current_user.support? || current_user == @user
    end
  end
end

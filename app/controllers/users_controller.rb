class UsersController < ApplicationController
  include Pagy::Backend
  include Devise::Controllers::SignInOut
  include Helpers::Email
  include Modules::SearchFilter

  before_action :authenticate_user!
  before_action :find_user, except: %i[new create]
  before_action :authenticate_scope!, except: %i[new]
  before_action :session_filters, if: :current_user, only: %i[index]
  before_action -> { filter_manager.serialize_filters_to_session }, if: :current_user, only: %i[index]

  def index
    redirect_to users_organisation_path(current_user.organisation) unless current_user.support?

    all_users = User.visible.sorted_by_organisation_and_role
    filtered_users = filter_manager.filtered_users(all_users, search_term, session_filters)
    @pagy, @users = pagy(filtered_users)
    @searched = search_term.presence
    @total_count = all_users.size
    @filter_type = "users"

    respond_to do |format|
      format.html
      format.csv do
        if current_user.support?
          send_data byte_order_mark + filtered_users.to_csv, filename: "users-#{Time.zone.now}.csv"
        else
          head :unauthorized
        end
      end
    end
  end

  def search
    user_options = current_user.support? ? User.all : User.own_and_managing_org_users(current_user.organisation)
    users = user_options.search_by(params["query"]).limit(20)

    user_data = users.each_with_object({}) do |user, hash|
      hash[user.id] = { value: user.name, hint: user.email }
    end

    render json: user_data.to_json
  end

  def resend_invite
    @user.send_confirmation_instructions
    flash[:notice] = "Invitation sent to #{@user.email}"
    render :show
  end

  def show; end

  def dpo; end

  def key_contact; end

  def edit
    redirect_to user_path(@user) unless @user.active?
  end

  def update
    validate_attributes
    if @user.errors.empty? && @user.update(user_params)
      if @user == current_user
        bypass_sign_in @user
        flash[:notice] = I18n.t("devise.passwords.updated") if user_params.key?("password")
        if user_params.key?("email")
          flash[:notice] = I18n.t("devise.email.updated", email: @user.unconfirmed_email)
        end

        redirect_to account_path
      else
        user_name = @user.name&.possessive || @user.email.possessive
        if user_params[:active] == "false"
          @user.deactivate!
          flash[:notice] = I18n.t("devise.activation.deactivated", user_name:)
        elsif user_params[:active] == "true"
          @user.reactivate!
          @user.send_confirmation_instructions
          flash[:notice] = I18n.t("devise.activation.reactivated", user_name:)
        elsif user_params.key?("email")
          flash[:notice] = I18n.t("devise.email.updated", email: @user.unconfirmed_email)
        end
        redirect_to user_path(@user)
      end
    elsif user_params.key?("password")
      format_error_messages
      @minimum_password_length = Devise.password_length.min
      render "devise/passwords/edit", locals: { resource: @user, resource_name: "user" }, status: :unprocessable_entity
    else
      format_error_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @organisation_id = params["organisation_id"]
    @user = User.new
  end

  def create
    @user = User.new(user_params.merge(org_params).merge(password_params))

    validate_attributes
    if @user.errors.empty? && @user.save
      redirect_to created_user_redirect_path
    else
      unless @user.errors[:organisation].empty?
        @user.errors.delete(:organisation)
      end
      render :new, status: :unprocessable_entity
    end
  end

  def edit_password
    @minimum_password_length = Devise.password_length.min
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

  def delete_confirmation
    authorize @user
  end

  def delete
    authorize @user
    @user.discard!
    redirect_to users_organisation_path(@user.organisation), notice: I18n.t("notification.user_deleted", name: @user.name)
  end

private

  def validate_attributes
    @user.validate
    if user_params[:role].present? && !current_user.assignable_roles.key?(user_params[:role].to_sym)
      @user.errors.add :role, I18n.t("validations.role.invalid")
    end

    if !user_params[:phone].nil? && user_params[:phone].blank?
      @user.errors.add :phone, :blank
    elsif !user_params[:phone].nil? && !valid_phone_number?(user_params[:phone])
      @user.errors.add :phone
    end
  end

  def valid_phone_number?(number)
    /^[+\d]{11,}$/.match?(number)
  end

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
        params.require(:user).permit(:email, :phone, :name, :password, :password_confirmation, :role, :is_dpo, :is_key_contact, :initial_confirmation_sent)
      else
        params.require(:user).permit(:email, :phone, :name, :password, :password_confirmation, :initial_confirmation_sent)
      end
    elsif current_user.data_coordinator?
      params.require(:user).permit(:email, :phone, :name, :role, :is_dpo, :is_key_contact, :active, :initial_confirmation_sent)
    elsif current_user.support?
      params.require(:user).permit(:email, :phone, :name, :role, :is_dpo, :is_key_contact, :organisation_id, :active, :initial_confirmation_sent)
    end
  end

  def created_user_redirect_path
    if current_user.support?
      users_path
    else
      users_organisation_path(current_user.organisation)
    end
  end

  def find_user
    @user = User.find_by(id: params[:user_id]) || User.find_by(id: params[:id]) || current_user
  end

  def authenticate_scope!
    if action_name == "create"
      head :unauthorized and return unless current_user.data_coordinator? || current_user.support?
    else
      render_not_found and return if @user.status == :deleted
      render_not_found and return unless (current_user.organisation == @user.organisation) || current_user.support?
      render_not_found and return if action_name == "edit_password" && current_user != @user
      render_not_found and return unless action_name == "show" ||
        current_user.data_coordinator? || current_user.support? || current_user == @user
    end
  end

  def filter_manager
    FilterManager.new(current_user:, session:, params:, filter_type: "users")
  end

  def session_filters
    filter_manager.session_filters
  end
end

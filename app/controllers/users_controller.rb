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
    users = User.visible(current_user).search_by(params["query"]).limit(20)

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
    redirect_to user_path(@user) unless @user.active? || current_user.support?
  end

  def update
    validate_attributes
    if @user.errors.empty? && @user.update(user_params_without_org)
      if @user == current_user
        bypass_sign_in @user
        flash[:notice] = I18n.t("devise.passwords.updated") if user_params.key?("password")
        if user_params.key?("email") && user_params[:email] != @user.email
          flash[:notice] = I18n.t("devise.email.updated", email: @user.unconfirmed_email)
        end

        if updating_organisation?
          redirect_to user_log_reassignment_path(@user, organisation_id: user_params[:organisation_id])
        else
          redirect_to account_path
        end
      else
        user_name = @user.name&.possessive || @user.email.possessive
        if user_params[:active] == "false"
          @user.deactivate!
          flash[:notice] = I18n.t("devise.activation.deactivated", user_name:)
        elsif user_params[:active] == "true"
          @user.reactivate!
          @user.send_confirmation_instructions
          flash[:notice] = I18n.t("devise.activation.reactivated", user_name:)
        elsif user_params.key?("email") && user_params[:email] != @user.email
          flash[:notice] = I18n.t("devise.email.updated", email: @user.unconfirmed_email)
        end

        if updating_organisation?
          redirect_to user_log_reassignment_path(@user, organisation_id: user_params[:organisation_id])
        else
          redirect_to user_path(@user)
        end
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

  def log_reassignment
    authorize @user
    assigned_to_logs_count = @user.assigned_to_lettings_logs.visible.count + @user.assigned_to_sales_logs.visible.count
    return redirect_to user_organisation_change_confirmation_path(@user, organisation_id: params[:organisation_id]) if assigned_to_logs_count.zero?

    if params[:organisation_id].present? && Organisation.where(id: params[:organisation_id]).exists?
      @new_organisation = Organisation.find(params[:organisation_id])
    else
      redirect_to user_path(@user)
    end
  end

  def update_log_reassignment
    authorize @user
    return redirect_to user_path(@user) unless log_reassignment_params[:organisation_id].present? && Organisation.where(id: log_reassignment_params[:organisation_id]).exists?

    @new_organisation = Organisation.find(log_reassignment_params[:organisation_id])

    validate_log_reassignment

    if @user.errors.empty?
      redirect_to user_organisation_change_confirmation_path(@user, log_reassignment_params)
    else
      render :log_reassignment, status: :unprocessable_entity
    end
  end

  def organisation_change_confirmation
    authorize @user
    assigned_to_logs_count = @user.assigned_to_lettings_logs.visible.count + @user.assigned_to_sales_logs.visible.count

    return redirect_to user_path(@user) if params[:organisation_id].blank? || !Organisation.where(id: params[:organisation_id]).exists?
    return redirect_to user_path(@user) if params[:log_reassignment].blank? && assigned_to_logs_count.positive?

    @new_organisation = Organisation.find(params[:organisation_id])
    @log_reassignment = params[:log_reassignment]
  end

  def confirm_organisation_change
    authorize @user
    assigned_to_logs_count = @user.assigned_to_lettings_logs.visible.count + @user.assigned_to_sales_logs.visible.count

    return redirect_to user_path(@user) if log_reassignment_params[:organisation_id].blank? || !Organisation.where(id: log_reassignment_params[:organisation_id]).exists?
    return redirect_to user_path(@user) if log_reassignment_params[:log_reassignment].blank? && assigned_to_logs_count.positive?

    @new_organisation = Organisation.find(log_reassignment_params[:organisation_id])
    @log_reassignment = log_reassignment_params[:log_reassignment]
    @user.reassign_logs_and_update_organisation(@new_organisation, @log_reassignment)

    redirect_to user_path(@user)
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

    if user_params.key?(:organisation_id) && user_params[:organisation_id].blank?
      @user.errors.add :organisation_id, :blank
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
      if current_user.data_coordinator?
        params.require(:user).permit(:email, :phone, :phone_extension, :name, :password, :password_confirmation, :role, :is_dpo, :is_key_contact, :initial_confirmation_sent)
      elsif current_user.support?
        params.require(:user).permit(:email, :phone, :phone_extension, :name, :password, :password_confirmation, :role, :is_dpo, :is_key_contact, :initial_confirmation_sent, :organisation_id)
      else
        params.require(:user).permit(:email, :phone, :phone_extension, :name, :password, :password_confirmation, :initial_confirmation_sent)
      end
    elsif current_user.data_coordinator?
      params.require(:user).permit(:email, :phone, :phone_extension, :name, :role, :is_dpo, :is_key_contact, :active, :initial_confirmation_sent)
    elsif current_user.support?
      params.require(:user).permit(:email, :phone, :phone_extension, :name, :role, :is_dpo, :is_key_contact, :organisation_id, :active, :initial_confirmation_sent)
    end
  end

  def user_params_without_org
    user_params.except(:organisation_id)
  end

  def log_reassignment_params
    params.require(:user).permit(:log_reassignment, :organisation_id)
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

  def updating_organisation?
    user_params["organisation_id"].present? && @user.organisation_id != user_params["organisation_id"].to_i
  end

  def validate_log_reassignment
    return @user.errors.add :log_reassignment, :blank if log_reassignment_params[:log_reassignment].blank?

    case log_reassignment_params[:log_reassignment]
    when "reassign_stock_owner"
      required_managing_agents = (@user.assigned_to_lettings_logs.visible.map(&:managing_organisation) + @user.assigned_to_sales_logs.visible.map(&:managing_organisation)).uniq
      current_managing_agents = @new_organisation.managing_agents
      missing_managing_agents = required_managing_agents - current_managing_agents

      if missing_managing_agents.any?
        new_organisation = @new_organisation.name
        missing_managing_agents = missing_managing_agents.map(&:name).sort.to_sentence
        @user.errors.add :log_reassignment, I18n.t("activerecord.errors.models.user.attributes.log_reassignment.missing_managing_agents", new_organisation:, missing_managing_agents:)
      end
    when "reassign_managing_agent"
      required_stock_owners = (@user.assigned_to_lettings_logs.visible.map(&:owning_organisation) + @user.assigned_to_sales_logs.visible.map(&:owning_organisation)).uniq
      current_stock_owners = @new_organisation.stock_owners
      missing_stock_owners = required_stock_owners - current_stock_owners

      if missing_stock_owners.any?
        new_organisation = @new_organisation.name
        missing_stock_owners = missing_stock_owners.map(&:name).sort.to_sentence
        @user.errors.add :log_reassignment, I18n.t("activerecord.errors.models.user.attributes.log_reassignment.missing_stock_owners", new_organisation:, missing_stock_owners:)
      end
    end
  end
end

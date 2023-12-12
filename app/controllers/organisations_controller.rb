class OrganisationsController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter
  include DuplicateLogsHelper

  before_action :authenticate_user!
  before_action :find_resource, except: %i[index new create]
  before_action :authenticate_scope!, except: [:index]
  before_action :session_filters, if: -> { current_user.support? || current_user.organisation.has_managing_agents? }, only: %i[lettings_logs sales_logs email_lettings_csv download_lettings_csv email_sales_csv download_sales_csv]
  before_action :session_filters, only: %i[users schemes]
  before_action -> { filter_manager.serialize_filters_to_session }, if: -> { current_user.support? || current_user.organisation.has_managing_agents? }, only: %i[lettings_logs sales_logs email_lettings_csv download_lettings_csv email_sales_csv download_sales_csv]
  before_action -> { filter_manager.serialize_filters_to_session }, only: %i[users schemes]

  def index
    redirect_to organisation_path(current_user.organisation) unless current_user.support?

    all_organisations = Organisation.order(:name)
    @pagy, @organisations = pagy(filtered_collection(all_organisations, search_term))
    @searched = search_term.presence
    @total_count = all_organisations.size
  end

  def schemes
    all_schemes = Scheme.where(owning_organisation: [@organisation] + @organisation.parent_organisations)

    @pagy, @schemes = pagy(filter_manager.filtered_schemes(all_schemes, search_term, session_filters).order_by_service_name)
    @searched = search_term.presence
    @total_count = all_schemes.size
    @filter_type = "schemes"
  end

  def show
    redirect_to details_organisation_path(@organisation)
  end

  def users
    organisation_users = @organisation.users.sorted_by_organisation_and_role
    unpaginated_filtered_users = filter_manager.filtered_users(organisation_users, search_term, session_filters)

    respond_to do |format|
      format.html do
        @pagy, @users = pagy(unpaginated_filtered_users)
        @searched = search_term.presence
        @total_count = @organisation.users.size
        @filter_type = "users"

        if current_user.support?
          render "users", layout: "application"
        else
          render "users/index"
        end
      end
      format.csv do
        send_data byte_order_mark + unpaginated_filtered_users.to_csv, filename: "users-#{@organisation.name}-#{Time.zone.now}.csv"
      end
    end
  end

  def details
    render "show"
  end

  def new
    @resource = Organisation.new
    render "new", layout: "application"
  end

  def create
    @resource = Organisation.new(org_params)
    if @resource.save
      redirect_to organisations_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if current_user.data_coordinator? || current_user.support?
      render "edit", layout: "application"
    else
      head :unauthorized
    end
  end

  def update
    if current_user.data_coordinator? || current_user.support?
      if @organisation.update(org_params)
        flash[:notice] = I18n.t("organisation.updated")
        redirect_to details_organisation_path(@organisation)
      end
    else
      head :unauthorized
    end
  end

  def lettings_logs
    organisation_logs = LettingsLog.visible.filter_by_organisation(@organisation)
    unpaginated_filtered_logs = filter_manager.filtered_logs(organisation_logs, search_term, session_filters)

    @search_term = search_term
    @pagy, @logs = pagy(unpaginated_filtered_logs)
    @delete_logs_path = delete_lettings_logs_organisation_path(search: @search_term)
    @searched = search_term.presence
    @total_count = organisation_logs.size
    @log_type = :lettings
    @filter_type = "lettings_logs"
    @duplicate_sets_count = FeatureToggle.duplicate_summary_enabled? ? duplicate_sets_count(current_user, @organisation) : 0
    render "logs", layout: "application"
  end

  def download_lettings_csv
    organisation_logs = LettingsLog.visible.where(owning_organisation_id: @organisation.id)
    unpaginated_filtered_logs = filter_manager.filtered_logs(organisation_logs, search_term, session_filters)
    codes_only = params.require(:codes_only) == "true"

    render "logs/download_csv", locals: { search_term:, count: unpaginated_filtered_logs.size, post_path: lettings_logs_email_csv_organisation_path, codes_only: }
  end

  def email_lettings_csv
    EmailCsvJob.perform_later(current_user, search_term, session_filters, false, @organisation, codes_only_export?)
    redirect_to lettings_logs_csv_confirmation_organisation_path
  end

  def sales_logs
    organisation_logs = SalesLog.visible.filter_by_organisation(@organisation)
    unpaginated_filtered_logs = filter_manager.filtered_logs(organisation_logs, search_term, session_filters)

    respond_to do |format|
      format.html do
        @search_term = search_term
        @pagy, @logs = pagy(unpaginated_filtered_logs)
        @delete_logs_path = delete_sales_logs_organisation_path(search: @search_term)
        @searched = search_term.presence
        @total_count = organisation_logs.size
        @log_type = :sales
        @filter_type = "sales_logs"
        @duplicate_sets_count = FeatureToggle.duplicate_summary_enabled? ? duplicate_sets_count(current_user, @organisation) : 0
        render "logs", layout: "application"
      end

      format.csv do
        send_data byte_order_mark + unpaginated_filtered_logs.to_csv, filename: "sales-logs-#{@organisation.name}-#{Time.zone.now}.csv"
      end
    end
  end

  def download_sales_csv
    organisation_logs = SalesLog.visible.where(owning_organisation_id: @organisation.id)
    unpaginated_filtered_logs = filter_manager.filtered_logs(organisation_logs, search_term, session_filters)
    codes_only = params.require(:codes_only) == "true"

    render "logs/download_csv", locals: { search_term:, count: unpaginated_filtered_logs.size, post_path: sales_logs_email_csv_organisation_path, codes_only: }
  end

  def email_sales_csv
    EmailCsvJob.perform_later(current_user, search_term, session_filters, false, @organisation, codes_only_export?, "sales")
    redirect_to sales_logs_csv_confirmation_organisation_path
  end

  def merge_request
    @merge_request = MergeRequest.new
  end

  def data_sharing_agreement
    @data_protection_confirmation = current_user.organisation.data_protection_confirmation
  end

  def confirm_data_sharing_agreement
    return render_not_found unless current_user.is_dpo?
    return render_not_found if @organisation.data_protection_confirmed?

    if @organisation.data_protection_confirmation
      @organisation.data_protection_confirmation.update!(
        confirmed: true,
        data_protection_officer: current_user,
        signed_at: Time.zone.now,
        organisation_name: @organisation.name,
        organisation_address: @organisation.address_row,
        organisation_phone_number: @organisation.phone,
        data_protection_officer_email: current_user.email,
        data_protection_officer_name: current_user.name,
      )
    else
      DataProtectionConfirmation.create!(
        organisation: @organisation,
        confirmed: true,
        data_protection_officer: current_user,
        signed_at: Time.zone.now,
        organisation_name: @organisation.name,
        organisation_address: @organisation.address_row,
        organisation_phone_number: @organisation.phone,
        data_protection_officer_email: current_user.email,
        data_protection_officer_name: current_user.name,
      )
    end

    flash[:notice] = "You have accepted the Data Sharing Agreement"
    flash[:notification_banner_body] = "Your organisation can now submit logs."

    redirect_to details_organisation_path(@organisation)
  end

  def changes
    render "schemes/changes"
  end

private

  def filter_type
    if params[:action].include?("lettings")
      "lettings_logs"
    elsif params[:action].include?("sales")
      "sales_logs"
    elsif params[:action].include?("users")
      "users"
    elsif params[:action].include?("schemes")
      "schemes"
    end
  end

  def session_filters
    filter_manager.session_filters
  end

  def filter_manager
    FilterManager.new(current_user:, session:, params:, filter_type:)
  end

  def org_params
    params.require(:organisation).permit(:name, :address_line1, :address_line2, :postcode, :phone, :holds_own_stock, :provider_type, :housing_registration_no)
  end

  def codes_only_export?
    params.require(:codes_only) == "true"
  end

  def search_term
    params["search"]
  end

  def authenticate_scope!
    if %w[create new lettings_logs sales_logs download_lettings_csv email_lettings_csv email_sales_csv download_sales_csv].include? action_name
      head :unauthorized and return unless current_user.support?
    elsif current_user.organisation != @organisation && !current_user.support?
      render_not_found
    end
  end

  def find_resource
    @organisation = Organisation.find(params[:id])
  end
end

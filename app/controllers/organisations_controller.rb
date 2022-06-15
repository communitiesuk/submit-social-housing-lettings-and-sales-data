class OrganisationsController < ApplicationController
  include Pagy::Backend
  include Modules::CaseLogsFilter
  include Modules::SearchFilter

  before_action :authenticate_user!
  before_action :find_resource, except: %i[index new create]
  before_action :authenticate_scope!, except: [:index]

  def index
    redirect_to organisation_path(current_user.organisation) unless current_user.support?

    all_organisations = Organisation.order(:name)
    @pagy, @organisations = pagy(filtered_collection(all_organisations, search_term))
    @searched = search_term.presence
    @total_count = all_organisations.size
  end

  def schemes
    all_schemes = Scheme.where(organisation: @organisation)

    @pagy, @schemes = pagy(filtered_collection(all_schemes, search_term))
    @searched = search_term.presence
    @total_count = all_schemes.size
  end

  def show
    redirect_to details_organisation_path(@organisation)
  end

  def users
    @pagy, @users = pagy(filtered_users(@organisation.users.sorted_by_organisation_and_role, search_term))
    @searched = search_term.presence
    @total_count = @organisation.users.size
    if current_user.support?
      render "users", layout: "application"
    else
      render "users/index"
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
    organisation = Organisation.create(org_params)
    if organisation.persisted?
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

  def logs
    if current_user.support?
      set_session_filters(specific_org: true)

      organisation_logs = CaseLog.all.where(owning_organisation_id: @organisation.id)
      unpaginated_filtered_logs = filtered_case_logs(filtered_collection(organisation_logs, search_term))

      @pagy, @case_logs = pagy(unpaginated_filtered_logs)
      @searched = search_term.presence
      @total_count = organisation_logs.size

      render "logs", layout: "application"
    else
      redirect_to(case_logs_path)
    end
  end

private

  def org_params
    params.require(:organisation).permit(:name, :address_line1, :address_line2, :postcode, :phone, :holds_own_stock, :provider_type, :housing_registration_no)
  end

  def search_term
    params["search"]
  end

  def authenticate_scope!
    if %w[create new].include? action_name
      head :unauthorized and return unless current_user.support?
    elsif current_user.organisation != @organisation && !current_user.support?
      render_not_found
    end
  end

  def find_resource
    @organisation = Organisation.find(params[:id])
  end
end

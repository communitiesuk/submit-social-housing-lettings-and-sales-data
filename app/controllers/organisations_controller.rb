class OrganisationsController < ApplicationController
  include Pagy::Backend
  include Modules::CaseLogsFilter

  before_action :authenticate_user!, except: [:index]
  before_action :find_resource, except: [:index]
  before_action :authenticate_scope!

  def index
    redirect_to organisation_path(current_user.organisation) unless current_user.support?

    @pagy, @organisations = pagy(Organisation.all)
  end

  def show
    redirect_to details_organisation_path(@organisation)
  end

  def users
    @pagy, @users = pagy(filtered_users)
    render "users/index"
  end

  def details
    render "show"
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
      @pagy, @case_logs = pagy(filtered_case_logs(organisation_logs))
      render "logs", layout: "application"
    else
      redirect_to(case_logs_path)
    end
  end

private

  def filtered_users
    search_param = params["user-search-field"]
    if search_param
      User.where("name ILIKE ?", "%#{search_param}%").where(active: true)
    else
      User.all.where(active: true)
    end
  end

  def org_params
    params.require(:organisation).permit(:name, :address_line1, :address_line2, :postcode, :phone)
  end

  def authenticate_scope!
    render_not_found if current_user.organisation != @organisation && !current_user.support?
  end

  def find_resource
    @organisation = Organisation.find(params[:id])
  end
end

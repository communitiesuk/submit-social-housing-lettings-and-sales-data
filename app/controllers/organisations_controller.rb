class OrganisationsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :find_resource, except: [:index]
  before_action :authenticate_scope!

  def index
    unless current_user.support?
      redirect_to user_path(current_user)
    end
  end

  def show
    redirect_to details_organisation_path(@organisation)
  end

  def users
    render "users"
  end

  def details
    render "show"
  end

  def edit
    if current_user.data_coordinator?
      render "edit", layout: "application"
    else
      head :unauthorized
    end
  end

  def update
    if current_user.data_coordinator?
      if @organisation.update(org_params)
        flash[:notice] = I18n.t("organisation.updated")
        redirect_to details_organisation_path(@organisation)
      end
    else
      head :unauthorized
    end
  end

private

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

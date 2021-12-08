class OrganisationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_resource
  before_action :authenticate_scope!

  def show
    redirect_to details_organisation_path(@organisation)
  end

  def users
    if current_user.data_coordinator?
      render "users"
    else
      head :unauthorized
    end
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
    head :not_found if current_user.organisation != @organisation
  end

  def find_resource
    @organisation = Organisation.find(params[:id])
  end
end

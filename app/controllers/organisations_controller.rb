class OrganisationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_organisation

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

private

  def find_organisation
    @organisation = Organisation.find(params[:id])
  end
end

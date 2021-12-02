class OrganisationsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_organisation

  def users
    if current_user.data_coordinator?
      render "users"
    else
      head :unauthorized
    end
  end

private

  def find_organisation
    @organisation = Organisation.find(params[:id])
  end
end

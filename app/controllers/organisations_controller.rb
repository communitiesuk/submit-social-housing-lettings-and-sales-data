class OrganisationsController < ApplicationController
  before_action :authenticate_user!

  def show
    @organisation = Organisation.find(params[:id])
  end
end

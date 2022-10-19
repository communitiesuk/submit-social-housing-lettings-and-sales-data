class OrganisationRelationshipsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!

  def housing_providers
    @housing_providers = organisation.housing_providers
  end

private

  def organisation
    @organisation ||= Organisation.find(params[:id])
  end
end

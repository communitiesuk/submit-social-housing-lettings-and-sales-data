class OrganisationRelationshipsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!

  def managing_agents
    # kick out if cannot access org

    @managing_agents = organisation.managing_agents
  end

  def housing_providers
    @housing_providers = organisation.housing_providers
  end

private

  def organisation
    @organisation ||= Organisation.find(params[:id])
  end
end

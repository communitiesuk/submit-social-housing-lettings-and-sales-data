class OrganisationRelationshipsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!

  def managing_agents
    # kick out if org isn't the current org

    @managing_agents = OrganisationRelationships.where(
      owning_organisation_id: organisation.id,
      relationship_type: :managing,
    )
  end

private

  def organisation
    @organisation ||= Organisation.find(params[:id])
  end
end

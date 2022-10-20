class OrganisationRelationshipsController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter


  before_action :authenticate_user!

  def managing_agents
    # kick out if cannot access org

    @managing_agents = organisation.managing_agents
  end

  def housing_providers
    housing_providers = organisation.housing_providers
    unpaginated_filtered_housing_providers = filtered_collection(housing_providers, search_term)
    respond_to do |format|
      format.html do
        @pagy, @housing_providers = pagy(unpaginated_filtered_housing_providers)
        @searched = search_term.presence
        @total_count = housing_providers.size
        if current_user.support?
          render "organisations/housing_providers", layout: "application"
        else
          render "organisation_relationships/housing_providers"
        end
      end
    end
  end

private

  def organisation
    @organisation ||= Organisation.find(params[:id])
  end

  def search_term
    params["search"]
  end
end

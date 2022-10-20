class OrganisationRelationshipsController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter


  before_action :authenticate_user!
  before_action :authenticate_scope!

  def housing_providers
    housing_providers = organisation.housing_providers
    unpaginated_filtered_housing_providers = filtered_collection(housing_providers, search_term)
    respond_to do |format|
      format.html do
        @pagy, @housing_providers = pagy(unpaginated_filtered_housing_providers)
        @searched = search_term.presence
        @total_count = housing_providers.size
        render "organisation_relationships/housing_providers", layout: "application"
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

  def authenticate_scope!
    if current_user.organisation != organisation
      render_not_found
    end
  end
end

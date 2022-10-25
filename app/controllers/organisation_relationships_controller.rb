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

  def add_housing_provider
    organisations = Organisation.all
    respond_to do |format|
      format.html do
        @organisations = organisations
        render "organisation_relationships/add_housing_provider", layout: "application"
      end
    end
  end

  def create
    @resource = OrganisationRelationship.new
    if params["related_organisation_id"] == nil
      @resource.errors.add :housing_providers, "Select a housing provider"
      return
    end
    @resource = OrganisationRelationship.new(child_organisation_id: @organisation.id, parent_organisation_id: related_organisation_params, relationship_type: 0)
    @resource.save!
    redirect_to housing_providers_organisation_path
  end

private

  def organisation
    @organisation ||= Organisation.find(params[:id])
  end

  def related_organisation_params
    params.require(:related_organisation_id)
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

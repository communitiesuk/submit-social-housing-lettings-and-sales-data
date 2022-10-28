class OrganisationRelationshipsController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter

  before_action :authenticate_user!
  before_action :authenticate_scope!

  def housing_providers
    housing_providers = organisation.housing_providers
    unpaginated_filtered_housing_providers = filtered_collection(housing_providers, search_term)
    organisations = Organisation.where.not(id: @organisation.id).pluck(:id, :name)
    respond_to do |format|
      format.html do
        @pagy, @housing_providers = pagy(unpaginated_filtered_housing_providers)
        @organisations = organisations
        @searched = search_term.presence
        @total_count = housing_providers.size
        render "organisation_relationships/housing_providers", layout: "application"
      end
    end
  end

  def managing_agents
    managing_agents = organisation.managing_agents
    unpaginated_filtered_managing_agents = filtered_collection(managing_agents, search_term)
    respond_to do |format|
      format.html do
        @pagy, @managing_agents = pagy(unpaginated_filtered_managing_agents)
        @searched = search_term.presence
        @total_count = managing_agents.size
        render "organisation_relationships/managing_agents", layout: "application"
      end
    end
  end

  def add_housing_provider
    @organisations = Organisation.where.not(id: @organisation.id).pluck(:id, :name)
    respond_to do |format|
      format.html do
        render "organisation_relationships/add_housing_provider", layout: "application"
      end
    end
  end

  def create_housing_provider
    child_organisation_id = @organisation.id
    parent_organisation_id = related_organisation_id
    relationship_type = OrganisationRelationship::OWNING
    if related_organisation_id.empty?
      @organisation.errors.add :related_organisation_id, "You must choose a housing provider"
      @organisations = Organisation.where.not(id: child_organisation_id).pluck(:id, :name)
      render "organisation_relationships/add_housing_provider"
      return
    elsif OrganisationRelationship.exists?(child_organisation_id:, parent_organisation_id:, relationship_type:)
      @organisation.errors.add :related_organisation_id, "You have already added this housing provider"
      @organisations = Organisation.where.not(id: child_organisation_id).pluck(:id, :name)
      render "organisation_relationships/add_housing_provider"
      return
    end
    create!(child_organisation_id:, parent_organisation_id:, relationship_type:)
    redirect_to housing_providers_organisation_path(related_organisation_id:)
  end

  def create!(child_organisation_id:, parent_organisation_id:, relationship_type:)
    @resource = OrganisationRelationship.new(child_organisation_id:, parent_organisation_id:, relationship_type:)
    @resource.save!
  end

private

  def organisation
    @organisation ||= Organisation.find(params[:id])
  end

  def related_organisation_id
    params["organisation"]["related_organisation_id"]
  end

  def search_term
    params["search"]
  end

  def authenticate_scope!
    if current_user.organisation != organisation && !current_user.support?
      render_not_found
    end
  end
end

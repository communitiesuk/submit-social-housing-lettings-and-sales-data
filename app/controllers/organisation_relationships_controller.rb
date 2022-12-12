class OrganisationRelationshipsController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter

  before_action :authenticate_user!
  before_action :authenticate_scope!

  def housing_providers
    housing_providers = organisation.housing_providers
    unpaginated_filtered_housing_providers = filtered_collection(housing_providers, search_term)
    organisations = Organisation.where.not(id: @organisation.id).pluck(:id, :name)
    respond_to :html
    @pagy, @housing_providers = pagy(unpaginated_filtered_housing_providers)
    @organisations = organisations
    @searched = search_term.presence
    @total_count = housing_providers.size
  end

  def managing_agents
    managing_agents = organisation.managing_agents
    unpaginated_filtered_managing_agents = filtered_collection(managing_agents, search_term)
    organisations = Organisation.where.not(id: @organisation.id).pluck(:id, :name)
    respond_to :html
    @pagy, @managing_agents = pagy(unpaginated_filtered_managing_agents)
    @organisations = organisations
    @searched = search_term.presence
    @total_count = managing_agents.size
  end

  def add_housing_provider
    @organisations = Organisation.where.not(id: @organisation.id).pluck(:id, :name)
    respond_to :html
  end

  def add_managing_agent
    @organisations = Organisation.where.not(id: @organisation.id).pluck(:id, :name)
    respond_to :html
  end

  def create_housing_provider
    child_organisation = @organisation
    if params[:organisation_relationship].present? && params[:organisation_relationship][:related_organisation_id].present?
      parent_organisation = related_organisation
    end
    @organisation_relationship = OrganisationRelationship.new(child_organisation:, parent_organisation:)
    if @organisation_relationship.save(context: :housing_provider)
      flash[:notice] = "#{related_organisation.name} is now one of #{current_user.data_coordinator? ? 'your' : "this organisation's"} housing providers"
      redirect_to housing_providers_organisation_path
    else
      @organisations = Organisation.where.not(id: child_organisation.id).pluck(:id, :name)
      render "organisation_relationships/add_housing_provider", status: :unprocessable_entity
    end
  end

  def create_managing_agent
    parent_organisation = @organisation
    if params[:organisation_relationship].present? && params[:organisation_relationship][:related_organisation_id].present?
      child_organisation = related_organisation
    end
    @organisation_relationship = OrganisationRelationship.new(child_organisation:, parent_organisation:)
    if @organisation_relationship.save(context: :managing_agent)
      flash[:notice] = "#{related_organisation.name} is now one of #{current_user.data_coordinator? ? 'your' : "this organisation's"} managing agents"
      redirect_to managing_agents_organisation_path
    else
      @organisations = Organisation.where.not(id: parent_organisation.id).pluck(:id, :name)
      render "organisation_relationships/add_managing_agent", status: :unprocessable_entity
    end
  end

  def remove_housing_provider
    @target_organisation_id = target_organisation.id
  end

  def delete_housing_provider
    relationship = OrganisationRelationship.find_by!(
      child_organisation: @organisation,
      parent_organisation: target_organisation,
    )
    relationship.destroy!
    flash[:notice] = "#{target_organisation.name} is no longer one of #{current_user.data_coordinator? ? 'your' : "this organisation's"} housing providers"
    redirect_to housing_providers_organisation_path
  end

  def remove_managing_agent
    @target_organisation_id = target_organisation.id
  end

  def delete_managing_agent
    relationship = OrganisationRelationship.find_by!(
      parent_organisation: @organisation,
      child_organisation: target_organisation,
    )
    relationship.destroy!
    flash[:notice] = "#{target_organisation.name} is no longer one of #{current_user.data_coordinator? ? 'your' : "this organisation's"} managing agents"
    redirect_to managing_agents_organisation_path
  end

private

  def create!(child_organisation:, parent_organisation:)
    @resource = OrganisationRelationship.new(child_organisation:, parent_organisation:)
    @resource.save!
  end

  def organisation
    @organisation ||= Organisation.find(params[:id])
  end

  def related_organisation
    @related_organisation ||= Organisation.find(params[:organisation_relationship][:related_organisation_id])
  end

  def target_organisation
    @target_organisation ||= Organisation.find(params[:target_organisation_id])
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

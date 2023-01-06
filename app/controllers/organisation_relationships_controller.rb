class OrganisationRelationshipsController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter

  before_action :authenticate_user!
  before_action :authenticate_scope!

  before_action :organisations
  before_action :target_organisation, only: %i[
    remove_stock_owner
    remove_managing_agent
    delete_stock_owner
    delete_managing_agent
  ]

  def stock_owners
    stock_owners = organisation.stock_owners
    unpaginated_filtered_stock_owners = filtered_collection(stock_owners, search_term)

    @pagy, @stock_owners = pagy(unpaginated_filtered_stock_owners)
    @searched = search_term.presence
    @total_count = stock_owners.size
  end

  def managing_agents
    managing_agents = organisation.managing_agents
    unpaginated_filtered_managing_agents = filtered_collection(managing_agents, search_term)

    @pagy, @managing_agents = pagy(unpaginated_filtered_managing_agents)
    @searched = search_term.presence
    @total_count = managing_agents.size
  end

  def add_stock_owner
    @organisation_relationship = organisation.parent_organisation_relationships.new
  end

  def add_managing_agent
    @organisation_relationship = organisation.child_organisation_relationships.new
  end

  def create_stock_owner
    @organisation_relationship = organisation.parent_organisation_relationships.new(organisation_relationship_params)
    if @organisation_relationship.save(context: :stock_owner)
      flash[:notice] = "#{@organisation_relationship.parent_organisation.name} is now one of #{current_user.data_coordinator? ? 'your' : "this organisation's"} stock owners"
      redirect_to stock_owners_organisation_path
    else
      @organisations = Organisation.where.not(id: organisation.id).pluck(:id, :name)
      render "organisation_relationships/add_stock_owner", status: :unprocessable_entity
    end
  end

  def create_managing_agent
    @organisation_relationship = organisation.child_organisation_relationships.new(organisation_relationship_params)
    if @organisation_relationship.save
      flash[:notice] = "#{@organisation_relationship.child_organisation.name} is now one of #{current_user.data_coordinator? ? 'your' : "this organisation's"} managing agents"
      redirect_to managing_agents_organisation_path
    else
      @organisations = Organisation.where.not(id: organisation.id).pluck(:id, :name)
      render "organisation_relationships/add_managing_agent", status: :unprocessable_entity
    end
  end

  def remove_stock_owner; end

  def delete_stock_owner
    OrganisationRelationship.find_by!(
      child_organisation: organisation,
      parent_organisation: target_organisation,
    ).destroy!
    flash[:notice] = "#{target_organisation.name} is no longer one of #{current_user.data_coordinator? ? 'your' : "this organisation's"} stock owners"
    redirect_to stock_owners_organisation_path
  end

  def remove_managing_agent; end

  def delete_managing_agent
    OrganisationRelationship.find_by!(
      parent_organisation: organisation,
      child_organisation: target_organisation,
    ).destroy!
    flash[:notice] = "#{target_organisation.name} is no longer one of #{current_user.data_coordinator? ? 'your' : "this organisation's"} managing agents"
    redirect_to managing_agents_organisation_path
  end

private

  def organisation
    @organisation ||= if current_user.support?
                        Organisation.find(params[:id])
                      else
                        current_user.organisation
                      end
  end

  def organisations
    @organisations ||= Organisation.where.not(id: organisation.id).pluck(:id, :name)
  end

  def parent_organisation
    @parent_organisation ||= Organisation.find(params[:organisation_relationship][:parent_organisation_id])
  end

  def child_organisation
    @child_organisation ||= Organisation.find(params[:organisation_relationship][:child_organisation_id])
  end

  def target_organisation
    @target_organisation ||= Organisation.find(params[:target_organisation_id])
  end

  def search_term
    params["search"]
  end

  def organisation_relationship_params
    params.require(:organisation_relationship).permit(:parent_organisation_id, :child_organisation_id)
  end

  def authenticate_scope!
    if current_user.organisation != Organisation.find(params[:id]) && !current_user.support?
      render_not_found
    end
  end
end

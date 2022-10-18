class HousingProvidersController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter

  def index
    housing_providers =
      Organisation.joins(:child_organisations)
                  .where(organisation_relationships: {
                    child_organisation_id: current_user.organisation_id,
                    relationship_type: OrganisationRelationship.relationship_types[:owning],
                  })
                  .order(:name)
    respond_to do |format|
      format.html do
        @pagy, @organisations = pagy(filtered_collection(housing_providers, search_term))
        @searched = search_term.presence
        @total_count = housing_providers.size
        render "housing_providers/index"
      end
    end
  end

private

  def search_term
    params["search"]
  end
end

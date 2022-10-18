class HousingProvidersController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter

  def index
    all_organisations = Organisation.order(:name)
    @pagy, @organisations = pagy(filtered_collection(all_organisations, search_term))
    @searched = search_term.presence
    @total_count = all_organisations.size
  end

private

  def search_term
    params["search"]
  end
end

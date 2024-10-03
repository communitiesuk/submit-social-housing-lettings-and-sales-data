class CollectionResourcesController < ApplicationController
  include CollectionResourcesHelper

  before_action :authenticate_user!

  def index
    render_not_found unless current_user.support?

    @mandatory_lettings_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("lettings", editable_collection_resource_years)
    @mandatory_sales_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("sales", editable_collection_resource_years)
  end
end

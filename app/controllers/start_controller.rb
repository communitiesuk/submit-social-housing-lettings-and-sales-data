class StartController < ApplicationController
  include CollectionResourcesHelper

  def index
    @mandatory_lettings_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("lettings", displayed_collection_resource_years)
    @mandatory_sales_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("sales", displayed_collection_resource_years)
    if current_user
      @homepage_presenter = HomepagePresenter.new(current_user)
      render "home/index"
    end
  end
end

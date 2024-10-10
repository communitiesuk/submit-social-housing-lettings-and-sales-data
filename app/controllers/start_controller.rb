class StartController < ApplicationController
  include CollectionResourcesHelper

  def index
    @mandatory_lettings_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("lettings", displayed_collection_resource_years)
    @mandatory_sales_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("sales", displayed_collection_resource_years)
    @additional_lettings_collection_resources_per_year = CollectionResource.where(log_type: "lettings", mandatory: false, year: displayed_collection_resource_years).group_by(&:year)
    @additional_sales_collection_resources_per_year = CollectionResource.where(log_type: "sales", mandatory: false, year: displayed_collection_resource_years).group_by(&:year)
    if current_user
      @homepage_presenter = HomepagePresenter.new(current_user)
      render "home/index"
    end
  end
end

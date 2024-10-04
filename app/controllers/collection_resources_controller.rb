class CollectionResourcesController < ApplicationController
  include CollectionResourcesHelper

  before_action :authenticate_user!

  def index
    render_not_found unless current_user.support?

    @mandatory_lettings_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("lettings", editable_collection_resource_years)
    @mandatory_sales_collection_resources_per_year = MandatoryCollectionResourcesService.generate_resources("sales", editable_collection_resource_years)
  end

  def download_mandatory_collection_resource
    log_type = params[:log_type]
    year = params[:year].to_i
    resource_type = params[:resource_type]

    return render_not_found unless resource_for_year_can_be_downloaded?(year)

    resource = MandatoryCollectionResourcesService.generate_resource(log_type, year, resource_type)
    return render_not_found unless resource

    download_resource(resource.download_filename)
  end

private

  def download_resource(filename)
    url = "https://#{Rails.application.config.collection_resources_s3_bucket_name}.s3.amazonaws.com/#{filename}"
    uri = URI.parse(url)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      send_data(response.body, disposition: "attachment", filename:)
    else
      render_not_found
    end
  end

  def resource_for_year_can_be_downloaded?(year)
    return true if current_user&.support? && editable_collection_resource_years.include?(year)

    displayed_collection_resource_years.include?(year)
  end
end

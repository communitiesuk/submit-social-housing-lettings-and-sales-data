class CollectionResource
  include ActiveModel::Model
  include Rails.application.routes.url_helpers

  attr_accessor :resource_type, :display_name, :short_display_name, :year, :log_type, :download_filename

  def download_path
    download_mandatory_collection_resource_path(log_type:, year:, resource_type:)
  end
end

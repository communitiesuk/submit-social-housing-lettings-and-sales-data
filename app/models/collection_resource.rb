class CollectionResource < ApplicationRecord
  include Rails.application.routes.url_helpers

  attr_accessor :file

  def download_path
    download_mandatory_collection_resource_path(log_type:, year:, resource_type:)
  end
end

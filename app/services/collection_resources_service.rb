class CollectionResourcesService
  def initialize
    @storage_service = if FeatureToggle.local_storage?
                         Storage::LocalDiskService.new
                       else
                         Storage::S3Service.new(Configuration::EnvConfigurationService.new, ENV["COLLECTION_RESOURCES_BUCKET"])
                       end
  end

  def get_file(file)
    @storage_service.get_file(file)
  rescue StandardError
    nil
  end

  def get_file_metadata(file)
    @storage_service.get_file_metadata(file)
  rescue StandardError
    nil
  end
end
